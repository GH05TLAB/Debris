using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class redCursor : MonoBehaviour {
    private Vector3 mousePosition;

    public Sprite red, none;

    private void Awake()
    {
        Manager.Instance.brushSize = 4;
    }

    // Update is called once per frame
    void Update () {

		Vector3 newSize = new Vector3 (Manager.Instance.brushSize, Manager.Instance.brushSize, 1);
        float moveSpeed = 2f;
        if (Manager.Instance.mySelection==1) {
            mousePosition = Input.mousePosition;
            mousePosition = Camera.main.ScreenToWorldPoint(mousePosition);
            transform.position = Vector2.Lerp(transform.position, mousePosition, moveSpeed);
            transform.localScale = newSize;
        }
	}
}
