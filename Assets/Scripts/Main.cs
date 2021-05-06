using System.Threading;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Main : MonoBehaviour
{
    void Start()
    {
        //启动lua主脚本,之后的事情都交由lua负责
        LuaManager.Instance.DoLuaFile("Main");
    }
}
