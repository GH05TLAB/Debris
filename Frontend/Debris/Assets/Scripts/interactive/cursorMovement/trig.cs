using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;

public class trig : MonoBehaviour {

    public GameObject scanning_noti;

    //not the best place to do this but whatevs, this works out well.
    private GameObject[] blinkers;
    private GameObject scan_off;
    private GameObject scan_on;

    //checking scans and cursor size
    private float size_check;
    private bool cursorOff;

    private void Awake()
    {
        blinkers = GameObject.FindGameObjectsWithTag("toggle");
        scan_off = GameObject.Find("scan_off");
        scan_on = GameObject.Find("scan_on");
    }

    private void OnTriggerStay2D(Collider2D col)
 	{
        if(!scanning_noti.activeSelf)
        {
            if (col.tag == "red" || col.tag == "green" || col.tag == "blue" || col.tag == "white" || col.tag.Contains("+"))
            {
                //blinker toggle should be off when brushing
                foreach(GameObject blinker in blinkers)
                    blinker.GetComponent<Toggle>().isOn = false;

                if (Input.GetMouseButton(0) == true && this.tag == "redCursor" && !col.tag.Contains("red"))
                {
                    //Debug.Log("works red");
                    mapBrushing.AssignLine("red", col.name);
                    Manager.Instance.flag = true;
                }
                else if (Input.GetMouseButton(0) == true && this.tag == "greenCursor" && !col.tag.Contains("green"))
                {
                    //Debug.Log("works green");
                    mapBrushing.AssignLine("green", col.name);
                    Manager.Instance.flag = true;
                }
                else if (Input.GetMouseButton(0) == true && this.tag == "blueCursor" && !col.tag.Contains("blue"))
                {
                    //Debug.Log("works blue");
                    mapBrushing.AssignLine("blue", col.name);
                    Manager.Instance.flag = true;
                }
                else if (Input.GetMouseButton(0) == true && this.tag == "whiteCursor" && col.tag != "white")
                {
                    mapBrushing.AssignLine("white", col.name);
                    Manager.Instance.flag = true;
                }
            }
            else if (col.tag == "AllColor")
            {
                if (Input.GetMouseButton(0) == true && this.tag == "whiteCursor" && col.tag != "white")
                {
                    mapBrushing.AssignLine("white", col.name);
                    Manager.Instance.flag = true;
                }
            }
            else
            {
                if (col.name == "no Cursor")
                {
                    if (!cursorOff)
                    {
                        cursorOff = true;
                        size_check = Manager.Instance.brushSize;
                        Manager.Instance.brushSize = 4;
                    }
                }
                else if (col.name == "on Cursor")
                {
                    if (cursorOff)
                    {
                        Manager.Instance.brushSize = size_check;
                        cursorOff = false;
                    }
                }
            }
        }
    }
}
