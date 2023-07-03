using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class FPS_Counter : MonoBehaviour
{
    public float frequency = 1;
    float sum = 0;
    int frames = 0;
    float time = 0;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        sum += (1.0f / Time.deltaTime);
        frames++;
        time += Time.deltaTime;

        if (time >= 1)
        {
            GetComponent<TMP_Text>().text = "FPS: " + (int)(sum / frames);
            time = 0;
            sum = 0;
            frames = 0;
        }
        
    }
}
