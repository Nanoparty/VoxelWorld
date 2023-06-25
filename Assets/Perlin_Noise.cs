using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Perlin_Noise : MonoBehaviour
{
    [SerializeField] int pixWidth;
    [SerializeField] int pixHeight;

    [SerializeField] float xOrg;
    [SerializeField] float yOrg;

    [SerializeField] float scale = 1.0f;

    [SerializeField] Gradient colorGradient;

    [Header("Tiles")]
    [SerializeField] GameObject WaterTile;
    [SerializeField] GameObject SandTile;
    [SerializeField] GameObject GrassTile;
    [SerializeField] GameObject StoneTile;
    [SerializeField] GameObject SnowTile;
    [SerializeField] GameObject Tree;
    [SerializeField] GameObject Rock;
    [SerializeField] GameObject Grass1;
    [SerializeField] GameObject Grass2;
    [SerializeField] GameObject Bush;

    private Texture2D texture;
    private Color[] pix;
    private Renderer rend;

    private List<GameObject> tiles;

    private void Start()
    {
        tiles = new List<GameObject>();
        rend = GetComponent<Renderer>();
        texture = new Texture2D(pixWidth, pixHeight);
        pix = new Color[texture.width * texture.height];
        rend.material.mainTexture = texture;

        CalculateNoise(new Vector2(xOrg, yOrg));
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Debug.Log("Generate");
            CalculateNoise(new Vector2(Random.Range(0, 1000), Random.Range(0,1000)));
        }
    }

    private void CalculateNoise(Vector2 offset)
    {
        float y = 0.0f;

        foreach(GameObject o in tiles)
        {
            Destroy(o);
        }
        tiles.Clear();

        while (y < texture.height)
        {
            float x = 0.0f;
            while (x < texture.width)
            {
                float xCoord = offset.x + x / texture.width * scale;
                float yCoord = offset.y + y / texture.height * scale;
                float sample = Mathf.PerlinNoise(xCoord, yCoord);
                //if (sample > 0.5f) sample = 1.0f;
                //else sample = 0.0f;
                //Debug.Log("Sample: " + sample);
                Color c = colorGradient.Evaluate(sample);
                int height = 15;
                if (sample < 0.3f)
                {
                    pix[(int)y * texture.width + (int)x] = Color.cyan;
                    GameObject o = Instantiate(WaterTile, new Vector3(x, height * 0.3f, y), Quaternion.identity);
                    tiles.Add(o);
                }
                else if (sample < 0.4f)
                {
                    pix[(int)y * texture.width + (int)x] = Color.yellow;
                    GameObject o = Instantiate(SandTile, new Vector3(x, height * sample, y), Quaternion.identity);
                    tiles.Add(o);
                }
                else if (sample < 0.7f)
                {
                    pix[(int)y * texture.width + (int)x] = Color.green;
                    GameObject o = Instantiate(GrassTile, new Vector3(x, height * sample, y), Quaternion.identity);
                    tiles.Add(o);

                    if (Random.Range(0,1f) > 0.8)
                    {
                        GameObject tree = Instantiate(Tree, new Vector3(x, height * sample + 1, y), Quaternion.identity);
                        tiles.Add(tree);
                    }
                    else if (Random.Range(0, 1f) > 0.9)
                    {
                        GameObject bush = Instantiate(Bush, new Vector3(x, height * sample + 1, y), Quaternion.identity);
                        tiles.Add(bush);
                    }
                    else if (Random.Range(0, 1f) > 0.9)
                    {
                        GameObject grass = Instantiate(Grass1, new Vector3(x, height * sample + 1, y), Quaternion.identity);
                        tiles.Add(grass);
                    }
                    else if (Random.Range(0, 1f) > 0.9)
                    {
                        GameObject grass = Instantiate(Grass2, new Vector3(x, height * sample + 1, y), Quaternion.identity);
                        tiles.Add(grass);
                    }
                }
                else if (sample < 0.84f)
                {
                    pix[(int)y * texture.width + (int)x] = Color.gray;
                    GameObject o = Instantiate(StoneTile, new Vector3(x, height * sample, y), Quaternion.identity);
                    tiles.Add(o);

                    if (Random.Range(0, 1f) > 0.8)
                    {
                        GameObject rock = Instantiate(Rock, new Vector3(x, height * sample + 1, y), Quaternion.identity);
                        tiles.Add(rock);
                    }
                }
                else if (sample >= 0.84f)
                {
                    pix[(int)y * texture.width + (int)x] = Color.white;
                    GameObject o = Instantiate(SnowTile, new Vector3(x, height * sample, y), Quaternion.identity);
                    tiles.Add(o);
                }

                

                //pix[(int)y * texture.width + (int)x] = c;

                //Instantiate(WaterTile, new Vector3(x, 1, y), Quaternion.identity);

                //pix[(int)y * texture.width + (int)x] = new Color(sample, sample, sample);

                x++;
            }
            y++;
        }
        texture.SetPixels(pix);
        texture.Apply();
    }
}
