using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Perlin_Noise : MonoBehaviour
{
    enum BlockType
    {
        AIR,
        DIRT,
        GRASS,
        SAND,
        WATER,
        STONE,
        SNOW
    }


    [SerializeField] int pixWidth;
    [SerializeField] int pixHeight;

    [SerializeField] float width;
    [SerializeField] float height;
    [SerializeField] float length;

    [SerializeField] float xOrg;
    [SerializeField] float yOrg;

    [SerializeField] float scale = 1.0f;

    [SerializeField] Gradient colorGradient;

    [Header("Tiles")]
    [SerializeField] GameObject WaterTile;
    [SerializeField] GameObject SandTile;
    [SerializeField] GameObject GrassTile;
    [SerializeField] GameObject DirtTile;
    [SerializeField] GameObject StoneTile;
    [SerializeField] GameObject SnowTile;
    [SerializeField] GameObject Tree;
    [SerializeField] GameObject Rock;
    [SerializeField] GameObject Grass1;
    [SerializeField] GameObject Grass2;
    [SerializeField] GameObject Bush;

    //private Texture2D texture;
    private Color[] pix;
    //private Renderer rend;

    private List<GameObject> tiles;

    private BlockType[, ,] chunk;

    private GameObject[,,] blocks;

    private void Start()
    {
        tiles = new List<GameObject>();
        //rend = GetComponent<Renderer>();
        //texture = new Texture2D(pixWidth, pixHeight);
        //pix = new Color[texture.width * texture.height];
        //rend.material.mainTexture = texture;
        chunk = new BlockType[(int)width, (int)length, (int)height];
        blocks = new GameObject[(int)width, (int)length, (int)height];

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < length; j++)
            {
                for (int k = 0; k < height; k++)
                {
                    chunk[i, j, k] = BlockType.AIR; blocks[i, j, k] = new GameObject();
                }
            }
        }

        CalculateNoise(new Vector2(xOrg, yOrg));
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Debug.Log("Generate");
            float random1 = Random.Range(0, 100);
            float random2 = Random.Range(0, 100);
            Debug.Log($"Offset {random1} {random2}");
            CalculateNoise(new Vector2(random1, random2));
        }

        if (Input.GetKeyDown(KeyCode.P))
        {
            //foreach(var tile in tiles)
            //{
            //    Destroy(tile.gameObject);
            //}
            //ClearHiddenBlocks();
        }
    }

    private void ClearHiddenBlocks()
    {
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < length; j++)
            {
                for (int k = 0; k < height; k++)
                {
                    Debug.Log($"{i} {j} {k}");
                    Destroy(blocks[i, j, k]);
                    continue;

                    if (i == 0 || i == width - 1) return;
                    if (j == 0 || j == length - 1) return;
                    if (k == 0 || k == height - 1) return;

                    if (chunk[i, j, k + 1] == BlockType.AIR || chunk[i, j, k - 1] == BlockType.AIR) return;
                    if (chunk[i, j + 1, k] == BlockType.AIR || chunk[i, j - 1, k] == BlockType.AIR) return;
                    if (chunk[i + 1, j, k] == BlockType.AIR || chunk[i - 1, j, k] == BlockType.AIR) return;

                    blocks[i, j, k].SetActive(false);

                }
            }
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

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < length; j++)
            {
                float sample = Mathf.PerlinNoise(offset.x + i / width * scale, offset.y + j / length * scale);
                int maxHeight = (int) (sample * (float)height);

                bool water = false;


                if (maxHeight < 0.3f * height)
                {
                    GameObject tile = Instantiate(WaterTile, new Vector3(i, 0.3f * height, j), Quaternion.identity);
                    tiles.Add(tile);
                    //blocks[i,j,(int)(0.3 * height)] = tile;
                    //chunk[i, j, (int)(0.3f * height)] = BlockType.WATER;
                    for (int k = (int)(0.3f * height) - 1; k >= maxHeight; k--)
                    {
                        GameObject tile2 = Instantiate(WaterTile, new Vector3(i, k, j), Quaternion.identity);
                        tiles.Add(tile2);
                        //blocks[i, j, k] = tile2;
                        //chunk[i, j, k] = BlockType.WATER;
                    }
                    water = true;
                }
                else if (maxHeight < 0.4f * height)
                {
                    GameObject tile = Instantiate(SandTile, new Vector3(i, maxHeight, j), Quaternion.identity);
                    tiles.Add(tile);
                    //blocks[i, j, maxHeight] = tile;
                    //chunk[i, j, maxHeight] = BlockType.SAND;
                }
                else if (maxHeight < 0.7f * height)
                {
                    GameObject tile = Instantiate(GrassTile, new Vector3(i, maxHeight, j), Quaternion.identity);
                    tiles.Add(tile);
                    //blocks[i, j, maxHeight] = tile;
                    //chunk[i, j, maxHeight] = BlockType.GRASS;

                    if (Random.Range(0, 1f) > 0.8)
                    {
                        GameObject tree = Instantiate(Tree, new Vector3(i, maxHeight + 1, j), Quaternion.identity);
                        tiles.Add(tree);
                    }
                    else if (Random.Range(0, 1f) > 0.9)
                    {
                        GameObject bush = Instantiate(Bush, new Vector3(i, maxHeight + 1, j), Quaternion.identity);
                        tiles.Add(bush);
                    }
                    else if (Random.Range(0, 1f) > 0.9)
                    {
                        GameObject grass = Instantiate(Grass1, new Vector3(i, maxHeight + 1, j), Quaternion.identity);
                        tiles.Add(grass);
                    }
                    else if (Random.Range(0, 1f) > 0.9)
                    {
                        GameObject grass = Instantiate(Grass2, new Vector3(i, maxHeight + 1, j), Quaternion.identity);
                        tiles.Add(grass);
                    }
                }
                else if (maxHeight < 0.84f * height)
                {
                    GameObject tile = Instantiate(StoneTile, new Vector3(i, maxHeight, j), Quaternion.identity);
                    tiles.Add(tile);
                    //blocks[i, j, maxHeight] = tile;
                    //chunk[i, j, maxHeight] = BlockType.STONE;

                    if (Random.Range(0, 1f) > 0.8)
                    {
                        GameObject rock = Instantiate(Rock, new Vector3(i, maxHeight + 1, j), Quaternion.identity);
                        tiles.Add(rock);
                        //chunk[i, j, maxHeight] = BlockType.SNOW;
                    }
                }
                else if (maxHeight >= 0.84f * height)
                {
                    GameObject tile = Instantiate(SnowTile, new Vector3(i, maxHeight, j), Quaternion.identity);
                    tiles.Add(tile);
                    //blocks[i, j, maxHeight] = tile;
                }


                for (int k = maxHeight - 1; k >= 0; k--)
                {
                    GameObject o2 = Instantiate(DirtTile, new Vector3(i, k, j), Quaternion.identity);
                    tiles.Add(o2);
                    //blocks[i, j, maxHeight] = o2;
                }
            }
        }


        //ClearHiddenBlocks();

        return;

        while (y < 100)
        {
            float x = 0.0f;
            while (x < 100)
            {
                //float xCoord = offset.x + x / texture.width * scale;
                //float yCoord = offset.y + y / texture.height * scale;
                float sample = Mathf.PerlinNoise(offset.x + x / 100 * scale, offset.y + y / 100 * scale);
                //if (sample > 0.5f) sample = 1.0f;
                //else sample = 0.0f;
                //Debug.Log("Sample: " + sample);
                Color c = colorGradient.Evaluate(sample);
                int height = 15;
                if (sample < 0.3f)
                {
                    //pix[(int)y * texture.width + (int)x] = Color.cyan;
                    GameObject o = Instantiate(WaterTile, new Vector3(x, height * 0.3f, y), Quaternion.identity);
                    tiles.Add(o);
                }
                else if (sample < 0.4f)
                {
                    //pix[(int)y * texture.width + (int)x] = Color.yellow;
                    GameObject o = Instantiate(SandTile, new Vector3(x, height * sample, y), Quaternion.identity);
                    tiles.Add(o);
                }
                else if (sample < 0.7f)
                {
                    //pix[(int)y * texture.width + (int)x] = Color.green;
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
                    //pix[(int)y * texture.width + (int)x] = Color.gray;
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
                    //pix[(int)y * texture.width + (int)x] = Color.white;
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
        //texture.SetPixels(pix);
        //texture.Apply();
    }
}
