using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class FPS_Counter : MonoBehaviour
{
    
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        GetComponent<TMP_Text>().text = "FPS: " + (1.0f / Time.deltaTime);
    }
}
