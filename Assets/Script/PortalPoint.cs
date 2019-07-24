using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalPoint : MonoBehaviour
{
    public string parameterName; 
    public Portal[] portals; 

    // Start is called before the first frame update
    void Start()
    {
        portals = FindObjectsOfType<Portal>();

        StartCoroutine(UpdatePoint());
    }

    private void OnDrawGizmosSelected()
    {
        portals = FindObjectsOfType<Portal>();


        for (int i = 0; i < portals.Length; i++)
        {
            portals[i].GetComponent<MeshRenderer>().sharedMaterial.SetVector(parameterName, transform.position);
        }
    }


    IEnumerator UpdatePoint()
    {
        for (int i = 0; i < portals.Length; i++)
        {
            portals[i].GetComponent<MeshRenderer>().material.SetVector(parameterName, transform.position);
        }

        yield return null;

        StartCoroutine(UpdatePoint());

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
