using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using CodeMonkey.Utils;

public class LineChart : MonoBehaviour {

    [SerializeField] private Sprite circleSprite;
    public RectTransform graphContainer;
    public RectTransform labelTemplateX;
    public RectTransform labelTemplateY;
    public RectTransform dashTemplateX;
    public RectTransform dashTemplateY;
    private List<float> valueList, valueList2;
    private int maxVisibleValue, maxVisibleValue2;
    private float values;
    private List<GameObject> gameObjectList;

    private void Awake()
    {
        maxVisibleValue = 0;
        maxVisibleValue2 = 0;

        //The value to be input into the chart
        valueList = new List<float>(); //profit
        valueList2 = new List<float>(); //time

        draw_background();
        //Create the graph, labelTemplateX and labelTemplateY
        //ShowGraph(valueList, (int _i) => "Iter." + (_i + 1));

        gameObjectList = new List<GameObject>();
    }

    //profit and then time
    public void reUpdate(float[] valueUpdate, float[] valueUpdate2, bool restart = false)
    {
        valueList.Clear();
        valueList2.Clear();
        maxVisibleValue = 0;

        //when we are not restarting for a new run
        if(!restart)
        {
            foreach (float value in valueUpdate)
            {
                valueList.Add(value);
            }

            foreach (float value in valueUpdate2)
            {
                valueList2.Add(value);
            }

            maxVisibleValue = valueUpdate.Length;

            maxVisibleValue = valueList.Count;

            List<float> time = new List<float>(valueList);
            List<float> profit = new List<float>(valueList2);

            ShowGraph(time, profit, maxVisibleValue, (int _i) => "S." + (_i + 1));
        }
        else
        {
            foreach (GameObject gameObject in gameObjectList)
            {
                Destroy(gameObject);
            }

            gameObjectList.Clear();
        }
    }

    //fix this function for new names
    public void update_graph()
    {
        if (this.name.Contains("current_"))
        {
            if (this.name.EndsWith("total"))
            {
                valueList.Add(Manager.Instance.minTime);
                valueList2.Add(Manager.Instance.maxProfit);
                maxVisibleValue++;

                List<float> time = new List<float>(valueList);
                List<float> profit = new List<float>(valueList2);

                ShowGraph(time, profit, maxVisibleValue, (int _i) => "S." + (_i + 1));
            }
        }
    }

    private GameObject CreateCircle(Vector2 anchoredPosition, string item)
    {
        GameObject gameObject = new GameObject("Knob", typeof(Image));
        gameObject.transform.SetParent(graphContainer, false);
        gameObject.GetComponent<Image>().sprite = circleSprite;
        if (item == "time")
            gameObject.GetComponent<Image>().color = Color.yellow;
        else if (item == "profit")
            gameObject.GetComponent<Image>().color = Color.blue;
        else
            gameObject.GetComponent<Image>().color = new Color(1, 1, 1, 0.5f);
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        rectTransform.anchoredPosition = anchoredPosition;
        rectTransform.sizeDelta = new Vector2(11, 11);
        rectTransform.anchorMin = new Vector2(0, 0);
        rectTransform.anchorMax = new Vector2(0, 0);
        return gameObject;
    }

    private void ShowGraph(List<float> valuelist_, List<float> valuelist2_, int maxVisibleValueAmount, Func<int, string> getAxisLableX = null, Func<float, string> getAxisLableY = null)
    {
        int valcheck = 0;
        float largest = 0, percent = 1;
        foreach (float value in valuelist_)
        {
            if (value > largest)
                largest = value;
        }

  //      if (largest > 10000000)
  //          percent = 10000;
  //      else if (largest > 1000000)
  //          percent = 1000;
  //      else if (largest > 100000)
  //          percent = 100;
  //      else if (largest > 10000)
  //          percent = 10;
  //      else
  //          percent = 1;

       //foreach (float value in valuelist_)
       //{
       //    valuelist_[valcheck] = value / percent;
       //    valcheck++;
       //}

        valcheck = 0;
        largest = 0; percent = 10;
        foreach (float value in valuelist2_)
        {
            if (value > largest)
                largest = value;
        }

//        if (largest > 10000000)
//            percent = 10000;
//        else if (largest > 1000000)
//            percent = 1000;
//        else if (largest > 100000)
//            percent = 100;
//        else if (largest > 10000)
//            percent = 10;
//        else
//            percent = 1;

        //foreach (float value in valuelist2_)
        //{
        //    valuelist2_[valcheck] = value / percent;
        //    valcheck++;
        //}

        if (getAxisLableX == null) {
            getAxisLableX = delegate (int _i) { return _i.ToString(); };
        }
        if (getAxisLableY == null) {
            getAxisLableY = delegate (float _f) { return Mathf.RoundToInt(_f).ToString(); };
        }

        foreach (GameObject gameObject in gameObjectList) {
            Destroy(gameObject);
        }

        gameObjectList.Clear();

        float graphWidth = graphContainer.sizeDelta.x;
        float graphHeight = graphContainer.sizeDelta.y*0.80f;

        //setting up max and mins for first line - profit
        float yMaximum = valuelist_[0];
        float yMinimum = valuelist_[0];

        for (int i = Mathf.Max(valuelist_.Count - maxVisibleValueAmount,0); i < valuelist_.Count; i++) {
            float value = valuelist_[i];
            if (value > yMaximum) {
                yMaximum = value;
            }
            if (value < yMinimum) {
                yMinimum = value;
            }
        }

        //setting up max and mins for the second line - time
        float yMaximum2 = valuelist2_[0];
        float yMinimum2 = valuelist2_[0];

        for (int i = Mathf.Max(valuelist2_.Count - maxVisibleValueAmount, 0); i < valuelist2_.Count; i++)
        {
            float value = valuelist2_[i];
            if (value > yMaximum2)
            {
                yMaximum2 = value;
            }
            if (value < yMinimum2)
            {
                yMinimum2 = value;
            }
        }

        /*float yMax, yMin;
        //caluclate the max mins for the whole graph/ how do you calculate this? 
            float yDiffmax = yMaximum - yMaximum2;
            if (yDiffmax <= 0)
            {
            yDiffmax = System.Math.Abs(yDiffmax) / graphHeight;
            }
            yMaximum = yMaximum + (yDiffmax * 0.2f);
            yMaximum2 = yMaximum2 + (yDiffmax * 0.2f);

            yMax = System.Math.Abs(yMaximum - yMaximum2);
            Debug.Log("ymx & ymx2: " + yMaximum + " " + yMaximum2);

            float yDiffmin = yMinimum - yMinimum2;
            if (yDiffmin <= 0)
            {
                yDiffmin = System.Math.Abs(yDiffmin) / graphHeight;
            }
            yMinimum = System.Math.Abs(yMinimum - (yDiffmin * 0.2f));
            yMinimum2 = System.Math.Abs(yMinimum2 - (yDiffmin * 0.2f));

            yMin = System.Math.Abs(yMinimum - yMinimum2);
            Debug.Log("ymn & ymn2: " + yMinimum + " " + yMinimum2);*/

        float xSize = (graphWidth / maxVisibleValueAmount);
        int xIndex = 0;
        int graph_size = 1;
        float Maxy;
        if (yMaximum > yMaximum2)
            Maxy = yMaximum;
        else
            Maxy = yMaximum2;

        //instantiate and setup each value dot on the graph and connecting them
        GameObject lastCircleGameObject = null, lastCircleGameObject2 = null;
        for (int i = Mathf.Max(valuelist_.Count - maxVisibleValueAmount, 0), j = Mathf.Max(valuelist2_.Count - maxVisibleValueAmount, 0); i < valuelist_.Count; i++, j++)
        {
            //x is same for both
            float xPosition = (xSize + xIndex * xSize)/2;

            //setup dots on the graph - profit
            // float yPosition = (valuelist_[i]) / (graphHeight * .15f);
            float yPosition = (graphHeight / Maxy) * valuelist_[i];
            Debug.Log("yPosition: " + yPosition + " time: " + valuelist_[i]);

            GameObject circleGameObject = CreateCircle(new Vector2(xPosition, yPosition), "time");
            gameObjectList.Add(circleGameObject);
            if (lastCircleGameObject != null)
            {
                GameObject dotConnecionGameObject = CreateDotConnection(lastCircleGameObject.GetComponent<RectTransform>().anchoredPosition, circleGameObject.GetComponent<RectTransform>().anchoredPosition, "profit");
                gameObjectList.Add(dotConnecionGameObject);
            }
            lastCircleGameObject = circleGameObject;

            if (i == valuelist_.Count - 1 || i ==0)
            {
                //Create the label for y axis info over dot for the first one - Profit
                RectTransform labelY = Instantiate(labelTemplateY);
                labelY.SetParent(graphContainer, false);
                labelY.gameObject.SetActive(true);
                labelY.sizeDelta = new Vector2();
                labelY.anchoredPosition = new Vector2(xPosition - 10, yPosition + 20);
                labelY.GetComponent<Text>().text = (((int)valueList[i]) / 1000).ToString();
                labelY.GetComponent<Text>().fontSize = 30;
                gameObjectList.Add(labelY.gameObject);
            }

            //setup dots on the graph - time 
            //float yPosition2 = (valuelist2_[j]) / (graphHeight * .15f);
            float yPosition2 = (graphHeight / Maxy) * valuelist2_[j];
            Debug.Log("yPosition2: " + yPosition2 + " profit: " + valuelist2_[j]);
            GameObject circleGameObject2 = CreateCircle(new Vector2(xPosition, yPosition2), "profit");
            gameObjectList.Add(circleGameObject2);
            if (lastCircleGameObject2 != null)
            {
                GameObject dotConnecionGameObject2 = CreateDotConnection(lastCircleGameObject2.GetComponent<RectTransform>().anchoredPosition, circleGameObject2.GetComponent<RectTransform>().anchoredPosition, "time");
                gameObjectList.Add(dotConnecionGameObject2);
            }
            lastCircleGameObject2 = circleGameObject2;

            if(i == valuelist_.Count - 1 || i == 0)
            {
                //Create the label for y axis info over dot for the second one - time
                RectTransform labelY2 = Instantiate(labelTemplateY);
                labelY2.SetParent(graphContainer, false);
                labelY2.gameObject.SetActive(true);
                labelY2.sizeDelta = new Vector2();
                labelY2.anchoredPosition = new Vector2(xPosition - 10, yPosition2 + 20);
                labelY2.GetComponent<Text>().text = (((int)valueList2[i]) / 1000).ToString();
                labelY2.GetComponent<Text>().fontSize = 30;
                gameObjectList.Add(labelY2.gameObject);
            }

            //Create the label for x axis
            RectTransform labelX = Instantiate(labelTemplateX);
            labelX.SetParent(graphContainer, false);
            labelX.gameObject.SetActive(true);
            labelX.anchoredPosition = new Vector2(xPosition, -5f);
            labelX.GetComponent<Text>().text = getAxisLableX(i);
            gameObjectList.Add(labelX.gameObject);

            //Create the vertical dash
            RectTransform dashX = Instantiate(dashTemplateX);
            dashX.SetParent(graphContainer, false);
            dashX.gameObject.SetActive(true);
            dashX.anchoredPosition = new Vector2(xPosition, -5f);
            gameObjectList.Add(dashX.gameObject);

            xIndex++;
        }
    }

    private void draw_background()
    {
        float graphWidth = graphContainer.sizeDelta.x;
        float graphHeight = graphContainer.sizeDelta.y;

        int separatorCount = 10;
        for (int i = 0; i <= separatorCount; i++)
        {
            float normalizeValue = i * 1f / separatorCount;
            //Create the horizontal dash
            RectTransform dashY = Instantiate(dashTemplateY);
            dashY.SetParent(graphContainer, false);
            dashY.gameObject.SetActive(true);
            dashY.anchoredPosition = new Vector2(-4f, normalizeValue * graphHeight);
        }
    }

    //Create the connection between dots
    private GameObject CreateDotConnection(Vector2 dotPositionA, Vector2 dotPositionB, string item)
    {
        GameObject gameObject = new GameObject("dotConnection", typeof(Image));
        gameObject.transform.SetParent(graphContainer, false);
        if(item == "profit")
            gameObject.GetComponent<Image>().color = Color.yellow;
        else if(item == "time")
            gameObject.GetComponent<Image>().color = Color.blue;
        else
            gameObject.GetComponent<Image>().color = new Color(1, 1, 1, 0.5f);

        Vector2 dir = (dotPositionB - dotPositionA).normalized;
        float distance = Vector2.Distance(dotPositionA, dotPositionB);
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        rectTransform.anchorMin = new Vector2(0, 0);
        rectTransform.anchorMax = new Vector2(0, 0);
        rectTransform.sizeDelta = new Vector2(distance, 3f);
        rectTransform.anchoredPosition = dotPositionA + dir * distance * .5f;
        rectTransform.localEulerAngles = new Vector3(0, 0, UtilsClass.GetAngleFromVectorFloat(dir));
        return gameObject;
    }
}
