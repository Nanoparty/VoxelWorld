using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class Controls : MonoBehaviour
{
    [SerializeField] TMP_InputField Width;
    [SerializeField] TMP_InputField Length;
    [SerializeField] TMP_InputField Height;
    [SerializeField] TMP_InputField Scale;
    [SerializeField] TMP_Dropdown Renderer;
    [SerializeField] Button Generate;

    private void Start()
    {
        Generate.onClick.AddListener(GenerateListener);

        Renderer.onValueChanged.AddListener(delegate { RendererListener(); });
    }

    private void GenerateListener()
    {
        int w = int.Parse(Width.text);
        int h = int.Parse(Height.text);
        int l = int.Parse(Length.text);
        float s = float.Parse(Scale.text);

        var type = Renderer.value;

        if (type == 0)
        {
            Standard_Instancer WorldGen = GameObject.FindGameObjectWithTag("Generator").GetComponent<Standard_Instancer>();

            WorldGen.WorldWidth = w;
            WorldGen.WorldLength = l;
            WorldGen.WorldHeight = h;
            WorldGen.WorldScale = s;

            WorldGen.Regenerate();
        }
    }

    private void RendererListener()
    {
        if (Renderer.value == 0 && SceneManager.GetActiveScene().name != "Standard_Instancing")
        {
            SceneManager.LoadScene("Standard_Instancing", LoadSceneMode.Single);
        }
        else if (Renderer.value == 1 && SceneManager.GetActiveScene().name != "GPU_Instancing")
        {
            SceneManager.LoadScene("GPU_Instancing", LoadSceneMode.Single);
        }
        else if (Renderer.value == 2 && SceneManager.GetActiveScene().name != "GPU_Caching")
        {
            SceneManager.LoadScene("GPU_Caching", LoadSceneMode.Single);
        }
    }
}
