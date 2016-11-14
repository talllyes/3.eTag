<%@ WebHandler Language="C#" Class="GetExcel" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using KaiValid;
using KaiClass;
using NPOI;
using NPOI.HSSF.UserModel;
using NPOI.XSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using System.Threading.Tasks;

public class GetExcel : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        string type = context.Items["type"].ToString();
        string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        if (type.Equals("週內日分時流量資料"))
        {
            int reportID = Int32.Parse(context.Request["id"].ToString());
            string te = (from a in DB.Report
                         where a.ReportID == reportID
                         select a.Context).FirstOrDefault();
            Excel1 excelJson = JsonConvert.DeserializeObject<Excel1>(te);


            ExcelCreate Excel = new ExcelCreate("1");
            eTag分時流量報表 報表 = excelJson.report;
            eTag基本資料 baseInfo = excelJson.baseInfo;
            Excel.sheetCreate("週日");
            Excel.設定週日內分時流量報表標題(baseInfo.date, "(" + baseInfo.ID + ")" + baseInfo.RoadName, "週日");
            foreach (var reportTemp in 報表.星期日)
            {
                List<dynamic> textTemp = new List<dynamic>();
                textTemp.Add(reportTemp.Hour);
                textTemp.Add(reportTemp.AllNums);
                textTemp.Add(reportTemp.SBigCarNums);
                textTemp.Add(reportTemp.BigCarNums);
                textTemp.Add(reportTemp.SmallCarNums);
                textTemp.Add(reportTemp.OtherCarNums);
                Excel.分時流量新增(textTemp);
            }
            Excel.setFooter();
            Excel.sheetCreate("週一");
            Excel.設定週日內分時流量報表標題(baseInfo.date, "(" + baseInfo.ID + ")" + baseInfo.RoadName, "週一");
            foreach (var reportTemp in 報表.星期一)
            {
                List<dynamic> textTemp = new List<dynamic>();
                textTemp.Add(reportTemp.Hour);
                textTemp.Add(reportTemp.AllNums);
                textTemp.Add(reportTemp.SBigCarNums);
                textTemp.Add(reportTemp.BigCarNums);
                textTemp.Add(reportTemp.SmallCarNums);
                textTemp.Add(reportTemp.OtherCarNums);
                Excel.分時流量新增(textTemp);
            }
            Excel.setFooter();
            Excel.sheetCreate("週二");
            Excel.設定週日內分時流量報表標題(baseInfo.date, "(" + baseInfo.ID + ")" + baseInfo.RoadName, "週二");
            foreach (var reportTemp in 報表.星期二)
            {
                List<dynamic> textTemp = new List<dynamic>();
                textTemp.Add(reportTemp.Hour);
                textTemp.Add(reportTemp.AllNums);
                textTemp.Add(reportTemp.SBigCarNums);
                textTemp.Add(reportTemp.BigCarNums);
                textTemp.Add(reportTemp.SmallCarNums);
                textTemp.Add(reportTemp.OtherCarNums);
                Excel.分時流量新增(textTemp);
            }
            Excel.setFooter();
            Excel.sheetCreate("週三");
            Excel.設定週日內分時流量報表標題(baseInfo.date, "(" + baseInfo.ID + ")" + baseInfo.RoadName, "週三");
            foreach (var reportTemp in 報表.星期三)
            {
                List<dynamic> textTemp = new List<dynamic>();
                textTemp.Add(reportTemp.Hour);
                textTemp.Add(reportTemp.AllNums);
                textTemp.Add(reportTemp.SBigCarNums);
                textTemp.Add(reportTemp.BigCarNums);
                textTemp.Add(reportTemp.SmallCarNums);
                textTemp.Add(reportTemp.OtherCarNums);
                Excel.分時流量新增(textTemp);
            }
            Excel.setFooter();
            Excel.sheetCreate("週四");
            Excel.設定週日內分時流量報表標題(baseInfo.date, "(" + baseInfo.ID + ")" + baseInfo.RoadName, "週四");
            foreach (var reportTemp in 報表.星期四)
            {
                List<dynamic> textTemp = new List<dynamic>();
                textTemp.Add(reportTemp.Hour);
                textTemp.Add(reportTemp.AllNums);
                textTemp.Add(reportTemp.SBigCarNums);
                textTemp.Add(reportTemp.BigCarNums);
                textTemp.Add(reportTemp.SmallCarNums);
                textTemp.Add(reportTemp.OtherCarNums);
                Excel.分時流量新增(textTemp);
            }
            Excel.setFooter();
            Excel.sheetCreate("週五");
            Excel.設定週日內分時流量報表標題(baseInfo.date, "(" + baseInfo.ID + ")" + baseInfo.RoadName, "週五");
            foreach (var reportTemp in 報表.星期五)
            {
                List<dynamic> textTemp = new List<dynamic>();
                textTemp.Add(reportTemp.Hour);
                textTemp.Add(reportTemp.AllNums);
                textTemp.Add(reportTemp.SBigCarNums);
                textTemp.Add(reportTemp.BigCarNums);
                textTemp.Add(reportTemp.SmallCarNums);
                textTemp.Add(reportTemp.OtherCarNums);
                Excel.分時流量新增(textTemp);
            }
            Excel.setFooter();
            Excel.sheetCreate("週六");
            Excel.設定週日內分時流量報表標題(baseInfo.date, "(" + baseInfo.ID + ")" + baseInfo.RoadName, "週六");
            foreach (var reportTemp in 報表.星期六)
            {
                List<dynamic> textTemp = new List<dynamic>();
                textTemp.Add(reportTemp.Hour);
                textTemp.Add(reportTemp.AllNums);
                textTemp.Add(reportTemp.SBigCarNums);
                textTemp.Add(reportTemp.BigCarNums);
                textTemp.Add(reportTemp.SmallCarNums);
                textTemp.Add(reportTemp.OtherCarNums);
                Excel.分時流量新增(textTemp);
            }
            Excel.setFooter();
            Excel.excelDownload(context, "多週內日分時流量報表");
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}


public class Excel1
{
    public eTag基本資料 baseInfo;
    public eTag分時流量報表 report;
}

public class eTag基本資料
{
    public string ID;
    public string RoadName;
    public string date;
}

public class eTag週內日分時流量
{
    public string 日期;
    public string 車種;
    public int 週內日;
    public int 小時;
    public int 數量;
}

public class eTag分時流量報表Row
{
    public string Hour;
    public int AllNums;
    public int SBigCarNums;
    public int BigCarNums;
    public int SmallCarNums;
    public int OtherCarNums;
}

public class eTag分時流量報表
{
    public List<eTag分時流量報表Row> 星期日;
    public List<eTag分時流量報表Row> 星期一;
    public List<eTag分時流量報表Row> 星期二;
    public List<eTag分時流量報表Row> 星期三;
    public List<eTag分時流量報表Row> 星期四;
    public List<eTag分時流量報表Row> 星期五;
    public List<eTag分時流量報表Row> 星期六;  
}