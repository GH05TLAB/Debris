using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextMove : MonoBehaviour {
    private Vector3 mousePosition;
    private float xMargin;
    private float yMargin;
    public int txtNUmber;
    // Use this for initialization
    void Start () {
		
	}
	
    // Update is called once per frame
    void Update()
    {

        Vector3 newSize = new Vector3(Manager.Instance.brushSize, Manager.Instance.brushSize, 1);
        float moveSpeed = 1f;
        if (Manager.Instance.mySelection >0)
        {
            mousePosition = Input.mousePosition;
            mousePosition = Camera.main.ScreenToWorldPoint(mousePosition);
            if (this.tag == "txtSelected")
            {
                switch (txtNUmber) { 
                    case 1:
                        xMargin =250.0f;
                        yMargin =200.0f;
                
                        break;
                    case 2:
                        xMargin = 250.0f;
                        yMargin = 320.0f;
                        break;
                    case 3:
                        xMargin = 250.0f;
                        yMargin = 440.0f;
                        break;
                    }
              //  mousePosition.Set(mousePosition.x - xMargin, mousePosition.y - yMargin, mousePosition.z);
              //  transform.position = Vector2.Lerp(transform.position, mousePosition, moveSpeed);
            }
            else
            {
            //    transform.position = Vector2.Lerp(transform.position, mousePosition, moveSpeed);
            //    transform.localScale = newSize;
            }
        }
    }

    void OnCollisionEnter2D(Collision2D other)
    {

        Debug.Log("ok");

    }

}
