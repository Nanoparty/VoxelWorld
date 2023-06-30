using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPU_Instancer : MonoBehaviour
{
    public int Instances;

    public Mesh mesh;
    public Material[] Materials1;

    public Material[] Materials2;

    [SerializeField] private Material _instanceMaterial;

    private List<List<Matrix4x4>> GrassBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> DirtBatches = new List<List<Matrix4x4>>();

    private readonly uint[] _args = { 0, 0, 0, 0, 0 };

    private ComputeBuffer _positionBuffer1, _positionBuffer2;
    private int _cachedMultiplier = 1;
    
    private ComputeBuffer _argsBuffer;


    private void RenderBatches(List<List<Matrix4x4>> Batch, Material[] Materials)
    {
        foreach (var batch in Batch)
        {
            for (int i = 0; i < mesh.subMeshCount; i++)
            {
                Graphics.DrawMeshInstanced(mesh, i, Materials[i], batch);
            }
        }
    }

    private void Update()
    {
        Graphics.DrawMeshInstancedIndirect(mesh, 0, _instanceMaterial, new Bounds(Vector3.one, Vector3.one* 10), _argsBuffer);
        //RenderBatches(GrassBatches, Materials1);
        //RenderBatches(DirtBatches, Materials2);
    }

    private void Start()
    {

        _argsBuffer = new ComputeBuffer(1, _args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        UpdateBuffers();

        // Grass Instancing
        //int AddedMatricies = 0;

        //GrassBatches.Add(new List<Matrix4x4>());

        //for (int i = 0; i < Instances; i++)
        //{
        //    if (AddedMatricies < 1000)
        //    {
        //        GrassBatches[GrassBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(Random.Range(0, 50), Random.Range(0, 50), Random.Range(0, 50)), Random.rotation, Vector3.one));
        //        AddedMatricies++;
        //    }
        //    else
        //    {
        //        GrassBatches.Add(new List<Matrix4x4>());
        //        AddedMatricies = 0;
        //    }
        //}

        //// Dirt Instancing
        //AddedMatricies = 0;

        //DirtBatches.Add(new List<Matrix4x4>());

        //for (int i = 0; i < Instances; i++)
        //{
        //    if (AddedMatricies < 1000)
        //    {
        //        DirtBatches[DirtBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(Random.Range(0, 50), Random.Range(0, 50), Random.Range(0, 50)), Random.rotation, Vector3.one));
        //        AddedMatricies++;
        //    }
        //    else
        //    {
        //        DirtBatches.Add(new List<Matrix4x4>());
        //        AddedMatricies = 0;
        //    }
        //}
    }

    private void UpdateBuffers()
    {
        // Positions
        _positionBuffer1?.Release();
        _positionBuffer2?.Release();
        _positionBuffer1 = new ComputeBuffer(Instances, 16);
        _positionBuffer2 = new ComputeBuffer(Instances, 16);

        var positions1 = new Vector4[Instances];
        var positions2 = new Vector4[Instances];

        // Grouping cubes into a bunch of spheres
        var offset = Vector3.zero;
        var batchIndex = 0;
        var batch = 0;
        for (var i = 0; i < Instances; i++)
        {
            //var dir = Random.insideUnitSphere.normalized;
            positions1[i] = new Vector3(i,i,i);
            positions2[i] = new Vector3(i, i, i);

            positions1[i].w = i;
            positions2[i].w = i;

            //if (batchIndex++ == 250000)
            //{
            //    batchIndex = 0;
            //    batch++;
            //    offset += new Vector3(90, 0, 0);
            //}
        }

        _positionBuffer1.SetData(positions1);
        _positionBuffer2.SetData(positions2);
        _instanceMaterial.SetBuffer("position_buffer_1", _positionBuffer1);
        _instanceMaterial.SetBuffer("position_buffer_2", _positionBuffer2);
        //_instanceMaterial.SetColorArray("color_buffer", SceneTools.Instance.ColorArray);

        // Verts
        _args[0] = mesh.GetIndexCount(0);
        _args[1] = (uint)Instances;
        _args[2] = mesh.GetIndexStart(0);
        _args[3] = mesh.GetBaseVertex(0);

        _argsBuffer.SetData(_args);
    }
}
