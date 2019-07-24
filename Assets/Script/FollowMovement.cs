using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowMovement : MonoBehaviour
{
    public float offset;
    public GameObject followObject;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

        //float tempoffset = Mathf.Lerp(-.5f, offset, transform.localPosition.magnitude/3);

        float tempoffset = offset;

        this.transform.localPosition = followObject.transform.localPosition + transform.forward * tempoffset;
       
        this.transform.localRotation = followObject.transform.localRotation;



    }
}
