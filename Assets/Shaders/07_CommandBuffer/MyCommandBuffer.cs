using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;


[ExecuteInEditMode]

public class MyCommandBuffer : MonoBehaviour
{
    public CameraEvent camEvent = CameraEvent.AfterForwardOpaque;

    private int bufferPrePass = Shader.PropertyToID("_PrePass");
    private int bufferAfterPass = Shader.PropertyToID("_AfterPass");

    private CommandBuffer cb;
    private Camera cam;
    public Material mat;

    void Awake()
    {
        CreateCommandBuffer();
    }

    void CreateCommandBuffer()
    {
        if (cb == null)
        {
            cb = new UnityEngine.Rendering.CommandBuffer();
            cb.name = "MyCommandBuffer";
        }
        else
        {
            cb.Clear();
        }

        if (cam == null)
            cam = Camera.main;

        if (mat == null)
            mat = new Material(Shader.Find("Unlit/PostProcess"));

        cam.AddCommandBuffer(camEvent, cb);


        RenderTextureDescriptor RTD = new RenderTextureDescriptor()
        {
            height = 1080,
            width = 1920,

            msaaSamples = 0,
            graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16_SFloat,

            dimension = TextureDimension.Tex2D,

            useMipMap = false
        };

        //cb.GetTemporaryRT(bufferPrePass, RTD,  FilterMode.Bilinear);

        cb.Blit(bufferPrePass, BuiltinRenderTextureType.CameraTarget, mat, 0);
    }
}
