<%@ WebHandler Language="C#" Class="GetReport" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using KaiValid;
using KaiClass;

public class GetReport : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        string type = context.Items["type"].ToString();
        if (type.Equals("多週內日分時旅行時間"))
        {
            var result = from a in DB.Report
                         where a.Type == 4
                         orderby a.CreateDate descending
                         select new
                         {
                             a.ReportID,
                             a.Name,
                             a.Context,
                             CreateDate = DateProcess.西元年轉民國年字串格式(a.CreateDate),
                             EndDate = DateProcess.西元年轉民國年字串格式(a.EndDate),
                             ReportStartDate = DateProcess.西元年轉民國年沒有分鐘回傳字串格式(a.ReportStartDate),
                             ReportEndDate = DateProcess.西元年轉民國年沒有分鐘回傳字串格式(a.ReportEndDate)
                         };

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("分時旅行時間查詢"))
        {
            var result = from a in DB.Report
                         where a.Type == 3
                         orderby a.CreateDate descending
                         select new
                         {
                             a.ReportID,
                             a.Name,
                             a.Context,
                             CreateDate = DateProcess.西元年轉民國年字串格式(a.CreateDate),
                             EndDate = DateProcess.西元年轉民國年字串格式(a.EndDate),
                             ReportStartDate = DateProcess.西元年轉民國年沒有分鐘回傳字串格式(a.ReportStartDate),
                             ReportEndDate = DateProcess.西元年轉民國年沒有分鐘回傳字串格式(a.ReportEndDate)
                         };

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("週內日分時流量資料"))
        {
            var result = from a in DB.Report
                         where a.Type == 2
                         orderby a.CreateDate descending
                         select new
                         {
                             a.ReportID,
                             a.Name,
                             a.Context,
                             CreateDate = DateProcess.西元年轉民國年字串格式(a.CreateDate),
                             EndDate = DateProcess.西元年轉民國年字串格式(a.EndDate),
                             ReportStartDate = DateProcess.西元年轉民國年沒有分鐘回傳字串格式(a.ReportStartDate),
                             ReportEndDate = DateProcess.西元年轉民國年沒有分鐘回傳字串格式(a.ReportEndDate)
                         };

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
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