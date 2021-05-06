--取别名

--Unity相关
GameObject = CS.UnityEngine.GameObject
Transform = CS.UnityEngine.Transform
RectTransform = CS.UnityEngine.RectTransform
TextAsset = CS.UnityEngine.TextAsset
Vector3 = CS.UnityEngine.Vector3
Vector2 = CS.UnityEngine.Vector2
Vector2Int = CS.UnityEngine.Vector2Int
Application = CS.UnityEngine.Application
AudioSource = CS.UnityEngine.AudioSource
Mathf = CS.UnityEngine.Mathf
Screen = CS.UnityEngine.Screen
ScreenOrientation = CS.UnityEngine.ScreenOrientation
--协程
WaitForSeconds = CS.UnityEngine.WaitForSeconds

--UI相关
UI = CS.UnityEngine.UI
Image = UI.Image
Text = UI.Text
Button = UI.Button
Toggle = UI.Toggle
ScrollRect = UI.ScrollRect
UIBehaviour = CS.UnityEngine.EventSystems.UIBehaviour

--DoTween相关
DOTween = CS.DG.Tweening.DOTween

--用于设置父类的，需要找到实例
Canvas = GameObject.Find("Canvas").transform

--自定义的相关C#脚本
AssetBundleManager = CS.AssetBundleManager.Instance
--自定义用来启动协程的脚本
ForCoroutine = CS.ForCoroutine
--lua解析器，释放lua时使用
LuaEnv = CS.LuaManager.Instance

--C#相关
Directory = CS.System.IO.Directory
Array = CS.System.Array
