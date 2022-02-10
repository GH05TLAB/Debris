using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Click_count : MonoBehaviour {
	//Highlight select
    private int count_reye = 0;//0
    private int count_beye = 0;//1
    private int count_geye = 0;//2
	//Brush select
	private int count_r = 0;//3
	private int count_b = 0;//4
	private int count_g = 0;//5
	private int count_unselect = 0;//6
    //Algo buttons
	private int count_scan = 0;//8
	private int count_advice = 0;//7
	private int count_clock = 0;//9
	private int count_money = 0;//10
	private int count_intersect = 0;//11
    //Misc
	private int count_undo = 0;//12
	private int count_redo = 0;//13
   

    public void press_count(int button_no)
	{
		switch(button_no)
		{
			case 0:
				count_reye++;
				break;
			case 1:
				count_beye++;
				break;
			case 2:
				count_geye++;
				break;
			case 3:
				count_r++;
				break;
			case 4:
				count_b++;
				break;
			case 5:
				count_g++;
				break;
			case 6:
				count_unselect++;
				break;
			case 7:
				count_advice++;
				break;
			case 8:
				count_scan++;
				break;
			case 9:
				count_clock++;
				break;
			case 10:
				count_money++;
				break;
			case 11:
				count_intersect++;
				break;
			case 12:
				count_undo++;
				break;
			case 13:
				count_redo++;
				break;
		}
	}

    /*
	void Update () 
	{
		Debug.Log("Red button pressed : " + count_r);
		Debug.Log("Green button pressed : " + count_g);
		Debug.Log("Blue button pressed : " + count_b);
	}
    */
}
