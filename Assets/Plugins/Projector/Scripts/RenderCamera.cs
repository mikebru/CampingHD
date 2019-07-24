using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderCamera : MonoBehaviour {

    public Transform Lookat;
    public Transform PositionTransform;

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {

        transform.LookAt(Lookat, Vector3.up);

        //Vector3 lookRotation = new Vector3(Camera.main.transform.rotation.eulerAngles.x, transform.rotation.eulerAngles.y, 0);

       // transform.rotation = Quaternion.Euler(lookRotation);

        transform.position = PositionTransform.position;
	}
}
