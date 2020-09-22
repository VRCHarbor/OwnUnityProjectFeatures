using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class GetterOfBlendShapes : MonoBehaviour
{

    #region Serialize Fields
    #endregion

    #region Private fields
    private Dictionary<int, string> _namesOfBlendShapes;
    private SkinnedMeshRenderer _meshRendererHandler;
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        _namesOfBlendShapes = new Dictionary<int, string>();
        this._meshRendererHandler = gameObject.GetComponentInChildren<SkinnedMeshRenderer>(false);

        //this._meshRendererHandler.sharedMesh
        if (this._meshRendererHandler != null)
        {
            Debug.Log(this._meshRendererHandler.name);
            for (int i = 0; i < this._meshRendererHandler.sharedMesh.blendShapeCount; ++i)
            {
                _namesOfBlendShapes.Add(i, this._meshRendererHandler.sharedMesh.GetBlendShapeName(i));
            }
        }
        else
        {
            Debug.LogWarning("NullReference");
        }

       
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.I))
        {
            Debug.Log(string.Concat(this._namesOfBlendShapes.Values));
        }
    }

    #region Public methods and fields

    #region Fields
    
    #endregion
    
    #region Methods
    /// <summary>
    /// Функция возврата мапа с шейп кеями для дальнейшего взаимодействия
    /// </summary>
    /// <returns>Мап</returns>
    public Dictionary<int, string> GetDictionaryOfBlendShapes() { return _namesOfBlendShapes; }

    /// <summary>
    /// Функция возврата листа с шейп кеями для дальнейшего взаимодействия
    /// </summary>
    /// <returns>Лист</returns>
    public List<string> GetNamesOfBlendShapes() { return _namesOfBlendShapes.Select(x => x.Value).ToList(); }

    #endregion

    #endregion
}
