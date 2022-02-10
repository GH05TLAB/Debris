using UnityEngine;
using System.Collections;
using System.Net;
using System.Net.Sockets;
using System.Linq;
using System;
using System.IO;
using System.Text;

public class classSocket : MonoBehaviour
{
    // Use this for initialization
    internal Boolean socketReady = false;
    TcpClient mySocket;
    NetworkStream theStream;
    StreamWriter theWriter;
    StreamReader theReader;
    String Host = "LocalHost";
    Int32 Port = 55002;
    
    public void setupSocket(bool new_run)
    {
        try
        {
            mySocket = new TcpClient(Host, Port);
            theStream = mySocket.GetStream();
            theWriter = new StreamWriter(theStream);
            socketReady = true;
            Byte[] sendBytes;
            
            if(!new_run)
                sendBytes = Encoding.UTF8.GetBytes("matlab can read CSV now!");
            else
                sendBytes = Encoding.UTF8.GetBytes("restart matlab read CSV!");

            mySocket.GetStream().Write(sendBytes, 0, sendBytes.Length);
            Debug.Log("socket is sent");
        }
        catch (Exception e)
        {
            Debug.Log("Socket error: " + e);
        }
    }
}
