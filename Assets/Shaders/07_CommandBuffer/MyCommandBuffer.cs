using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Serialization;
#if UNITY_EDITOR
using UnityEditor;
#endif


[ExecuteInEditMode]

public class MyCommandBuffer : MonoBehaviour
{

    [ColorUsageAttribute(true, true)] public Color rimLightColor = Color.white;
    public float blurSize = 0.05f;
    public float _MipLVL = 4.0f;

    public Shader Shader;



    //list of all renderer components you want to have outlines as single silhouete
    public Renderer[] renderers;
    const string shaderName = "Unlit/PostProcess";


    //shader Pass Indices
    private const int SHADER_PASS_MASK = 0;
    private const int SHADER_PASS_BLUR = 1;
    private const int SHADER_PASS_ADDITIVE = 2;


    //render texture IDs
    private int maskBuffer = Shader.PropertyToID("_Mask");
    private int glowBuffer = Shader.PropertyToID("_Glow");
    private int mainBuffer = Shader.PropertyToID("_Main");

    //private variables
    private CommandBuffer cb;
    private Camera cam;
    public Material mat;
    public CameraEvent cameraEvent = CameraEvent.BeforeForwardOpaque;


    private Mesh MeshFromRenderer(Renderer r)
    {
        if (r is MeshRenderer)
            return r.GetComponent<MeshFilter>().sharedMesh;

        return null;
    }

    private void CreateCommandBuffer(Camera cam)
    {
        if ((renderers == null) || (renderers.Length == 0))
            return;

        if(cb == null)
        {
            cb = new UnityEngine.Rendering.CommandBuffer();
            cb.name = "MyCommandBuffer: " + gameObject.name;
        }
        else
        {
            cb.Clear();
        }


        if(mat == null)
        {
            mat = new Material(Shader != null ? Shader : Shader.Find(shaderName));
        }

        //do nothing if no rimlight will be visible
        if(rimLightColor.a <= (1f/255f) || blurSize <= 0f)
        {
            cb.Clear();
            return;
        }

        //support meshes with sub meshes
        //can be from having multiple materials, complex skinning rigs, or a lot of vertices
        int renderersCount = renderers.Length;
        int[] subMeshCount = new int [renderersCount];

        for(int i = 0; i < renderersCount; i++)
        {
            var mesh = MeshFromRenderer(renderers[i]);

            if(mesh != null)
            {
                //assume saticly batched meshes only have one sub mesh
                if (renderers[i].isPartOfStaticBatch)
                    subMeshCount[i] = 1; //hack hack hack 
                else
                    subMeshCount[i] = mesh.subMeshCount;
            }
        }

        //match current quality settings' MSAA settings
        //doesn't check if current camera has MSAA enabled
        //also could just always do MSAA if you so pleased

        int msaa = 1; 
        int width = cam.scaledPixelWidth;
        int height = cam.scaledPixelHeight;


        // setup descriptor for descriptor of inverted alpha render texture
        RenderTextureDescriptor MaskRTD = new RenderTextureDescriptor()
        {
            dimension = TextureDimension.Tex2D,
            graphicsFormat = GraphicsFormat.A10R10G10B10_XRUNormPack32,

            width = width,
            height = height,

            msaaSamples = msaa,
            depthBufferBits = 0,

            sRGB = false,

            useMipMap = true,
            autoGenerateMips = true
        };

        cb.GetTemporaryRT(maskBuffer, MaskRTD, FilterMode.Trilinear);

        // render meshes to main buffer for the interior stencil mask
        cb.SetRenderTarget(maskBuffer);
        cb.ClearRenderTarget(true, true, Color.clear);
        for (int i = 0; i < renderersCount; i++)
        {
            for (int m = 0; m < subMeshCount[i]; m++)
            {
                cb.DrawRenderer(renderers[i], mat, m, SHADER_PASS_MASK);

            }
        }

        //cb.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);

        // setup descriptor for descriptor of inverted alpha render texture
        RenderTextureDescriptor GlowRTD = new RenderTextureDescriptor()
        {
            dimension = TextureDimension.Tex2D,
            graphicsFormat = GraphicsFormat.A10R10G10B10_XRUNormPack32,

            width = width,
            height = height,

            msaaSamples = msaa,
            depthBufferBits = 0,

            sRGB = false,

            useMipMap = true,
            autoGenerateMips = true
        };

        mat.SetFloat("_Distance", blurSize);
        mat.SetFloat("_MipLVL", _MipLVL);

        // create silhouette buffer and assign it as the current render target
        cb.GetTemporaryRT(glowBuffer, GlowRTD, FilterMode.Trilinear);
        cb.Blit(maskBuffer, glowBuffer, mat, SHADER_PASS_BLUR);

        // seteamos el render target actual al de la camara de nuevo
        cb.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);

       // mat.SetTexture("_Main",BuiltinRenderTextureType.CameraTarget);
        cb.Blit(glowBuffer, BuiltinRenderTextureType.CameraTarget, mat, SHADER_PASS_ADDITIVE);

        cb.ReleaseTemporaryRT(maskBuffer);
        cb.ReleaseTemporaryRT(glowBuffer);
        cb.ReleaseTemporaryRT(mainBuffer);
    }


    void RemoveCommandBuffer(Camera cam)
    {
        if(this.cam != null && cb != null)
        {
            this.cam.RemoveCommandBuffer(cameraEvent, cb);
            this.cam = null;
        }
    }

    void ApplyCommandBuffer(Camera cam)
    {
        CreateCommandBuffer(cam);
        if (cb == null)
            return;

        this.cam = cam;

        this.cam.AddCommandBuffer(cameraEvent, cb);
    }



    void OnEnable()
    {
        Camera.onPreRender += ApplyCommandBuffer;
        Camera.onPostRender += RemoveCommandBuffer;
    }

    void OnDisable()
    {
        Camera.onPreRender -= ApplyCommandBuffer;
        Camera.onPostRender -= RemoveCommandBuffer;
    }



#if UNITY_EDITOR
    void OnValidate()
    {
        
    }
#endif
}
