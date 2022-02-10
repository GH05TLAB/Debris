using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using CodeMonkey.Utils;

public class BarChart : MonoBehaviour
{

    [SerializeField] private Sprite dotSprite;
    public RectTransform graphContainer;
    public RectTransform labelTemplateX;
    public RectTransform labelTemplateY;
    public RectTransform dashTemplateX;
    public RectTransform dashTemplateY;
    private List<GameObject> gameObjectList;
    private List<float> valueList;
    private int maxVisibleValue;
    private float values;

    private void Awake()
    {
        gameObjectList = new List<GameObject>();

        maxVisibleValue = 0;
        //The input value
        valueList = new List<float>();

        //Create the graph, labelTemplateX and labelTemplateY
        //ShowGraph(valueList, (int _i) => "Iter." + (_i + 1));
        draw_background();
    }

    public void reUpdate(List<float> valueUpdate, bool restart = false)
    {
        valueList.Clear();
        maxVisibleValue = 0;

        //when we are not restarting for a new run
        if(!restart)
        {
            foreach (float value in valueUpdate)
            {
                valueList.Add(value);
                maxVisibleValue++;
            }
            ShowGraph(valueList, maxVisibleValue, (int _i) => "CNC." + (_i + 1));
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

    public void update_graph()
    {
        if (this.name.Contains("current_"))
        {
            valueList.Clear();
            maxVisibleValue = 0;

            if (this.name.EndsWith("time"))
            {
                valueList.Add(Manager.Instance.cncTime[0]);
                maxVisibleValue++;
                valueList.Add(Manager.Instance.cncTime[1]);
                maxVisibleValue++;
                valueList.Add(Manager.Instance.cncTime[2]);
                maxVisibleValue++;

                ShowGraph(valueList, maxVisibleValue, (int _i) => "CNC." + (_i + 1));
            }
            else if (this.name.EndsWith("profit"))
            {
                valueList.Add(Manager.Instance.cncProfit[0]);
                maxVisibleValue++;
                valueList.Add(Manager.Instance.cncProfit[1]);
                maxVisibleValue++;
                valueList.Add(Manager.Instance.cncProfit[2]);
                maxVisibleValue++;

                ShowGraph(valueList, maxVisibleValue, (int _i) => "CNC." + (_i + 1));
            }
        }
    }

    private GameObject CreateDot(Vector2 anchoredPosition)
    {
        GameObject gameObject = new GameObject("Dot", typeof(Image));
        gameObject.transform.SetParent(graphContainer, false);
        gameObject.GetComponent<Image>().sprite = dotSprite;
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        rectTransform.anchoredPosition = anchoredPosition;
        rectTransform.sizeDelta = new Vector2(11, 11);
        rectTransform.anchorMin = new Vector2(0, 0);
        rectTransform.anchorMax = new Vector2(0, 0);
        return gameObject;
    }

    private void ShowGraph(List<float> valuelist_, int maxVisibleValueAmount, Func<int, string> getAxisLableX = null, Func<float, string> getAxisLableY = null)
    {
        int valcheck = 0;
        float largest = 0, percent = 1;
        foreach(float value in valuelist_)
        {
            if(value > largest)
                largest = value;
        }

   //     if (largest > 10000000)
   //         percent = 10000;
   //     else if (largest > 1000000)
   //         percent = 1000;
   //     else if (largest > 100000)
   //         percent = 100;
   //     else if (largest > 10000)
   //         percent = 10;
   //     else
   //         percent = 1;

      // foreach (float value in valuelist_)
      // {
      //     valuelist_[valcheck] = value / percent;
      //     valcheck++;
      // }


        if (getAxisLableX == null)
        {
            getAxisLableX = delegate (int _i) { return _i.ToString(); };
        }
        if (getAxisLableY == null)
        {
            getAxisLableY = delegate (float _f) { return Mathf.RoundToInt(_f).ToString(); };
        }

        foreach (GameObject gameObject in gameObjectList)
        {
            Destroy(gameObject);
        }

        gameObjectList.Clear();


        float graphWidth = graphContainer.sizeDelta.x;
        float graphHeight = (graphContainer.sizeDelta.y)*0.8f;

        int yMaximum = (int)(valuelist_[0]);
        int yMinimum = (int)(valuelist_[0]);

        for (int i = Mathf.Max(valuelist_.Count - maxVisibleValueAmount, 0); i < valuelist_.Count; i++)
        {
            int value = (int)valuelist_[i];
            if (value > yMaximum)
            {
                yMaximum = value;
            }
            if (value < yMinimum)
            {
                yMinimum = value;
            }
        }

        float yDifference = yMaximum - yMinimum;
        if (yDifference <= 0)
        {
            yDifference = 5f;
        }
        yMaximum = yMaximum + (int)(yDifference * 0.2f);
        yMinimum = yMinimum - (int)(yDifference * 0.2f);

        float xSize = graphWidth / maxVisibleValueAmount;

        int xIndex = 0;

        //GameObject lastDotGameObject = null;
        for (int i = Mathf.Max(valuelist_.Count - maxVisibleValueAmount, 0), j = 0; i < valuelist_.Count; i++, j++)
        {
            float xPosition = xSize * 0.5f + xIndex * xSize;
            float yPosition = (graphHeight / yMaximum) * valuelist_[i];

            if (valuelist_[i] == 0)
                yPosition = 5;

            GameObject barGameObject = CreateBar(new Vector2(xPosition, yPosition), xSize * 0.8f, j);           
            gameObjectList.Add(barGameObject);

            //Create the label for y axis info over bar
            RectTransform labelY = Instantiate(labelTemplateY);
            labelY.SetParent(graphContainer, false);
            labelY.gameObject.SetActive(true);
            labelY.sizeDelta = new Vector2(2f,2f);
            labelY.anchoredPosition = new Vector2(xPosition + 25, yPosition + 10);
            labelY.GetComponent<Text>().text = (((int)valueList[i])/1000).ToString();
            labelY.GetComponent<Text>().fontSize = 30;
            gameObjectList.Add(labelY.gameObject);

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

    private GameObject CreateBar(Vector2 graphPosition, float barWidth, int cnc)
    { 
        Color[] cnc_color = { Color.red, Color.green, Color.blue };
        GameObject gameObject = new GameObject("Bar", typeof(Image));
        gameObject.transform.SetParent(graphContainer, false);
        if(cnc < 3)
            gameObject.GetComponent<Image>().color = cnc_color[cnc];
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        rectTransform.anchoredPosition = new Vector2(graphPosition.x, 0f);
        rectTransform.sizeDelta = new Vector2(barWidth, graphPosition.y);
        rectTransform.anchorMin = new Vector2(0, 0);
        rectTransform.anchorMax = new Vector2(0, 0);
        rectTransform.pivot = new Vector2(0.5f, 0f);
        return gameObject;
    }
}

