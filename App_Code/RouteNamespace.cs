using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Compilation;
using System.Web.Hosting;
using System.Web.Routing;

/// <summary>
/// RouteNamespace 的摘要描述
/// </summary>
/// 
namespace RouteNamespace
{
    //限制無法使用html讀取網頁
    public class NoHtmlLoad : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            //用html讀都放送~/Views/other/noFound.html內容
            var handler = BuildManager.CreateInstanceFromVirtualPath("~/Web/other/noFound.html", typeof(IHttpHandler)) as IHttpHandler;
            context.Server.Transfer(handler, false);
        }
        public bool IsReusable
        {
            get
            {
                return true;
            }
        }
    }
    //限制無法使用ashx讀取網頁
    public class NoAshxLoad : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            //用ashx讀都放送~/Views/other/noFound.html內容
            var handler = BuildManager.CreateInstanceFromVirtualPath("~/Web/other/noFound.html", typeof(IHttpHandler)) as IHttpHandler;
            context.Server.Transfer(handler, false);
        }
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }

    //Web目錄Html的自動Route
    public class WebHtmlRoute : IRouteHandler
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            var routeData = requestContext.RouteData;
            //取出參數
            string htmlUrl = Convert.ToString(routeData.Values["htmlUrl"]);
            //檢查看看有無該Model對應的HTML?
            string htmlName = htmlUrl + ".html";
            if (!File.Exists(HostingEnvironment.MapPath("~/Web/" + htmlName)))
            {
                //導向至login
                requestContext.HttpContext.Response.Redirect("~/login");
            }
            //導向指定的HTML
            return BuildManager.CreateInstanceFromVirtualPath("~/Web/"+ htmlName, typeof(IHttpHandler)) as IHttpHandler;
        }
    }
    //Web/template目錄Html的自動Route
    public class WebTemplateHtmlRoute : IRouteHandler
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            var routeData = requestContext.RouteData;
            //取出參數
            string htmlUrl = Convert.ToString(routeData.Values["htmlUrl"]);
            //檢查看看有無該Model對應的HTML?
            string htmlName = htmlUrl + ".html";
            if (!File.Exists(HostingEnvironment.MapPath("~/Web/Template/" + htmlName)))
            {
                //導向至找不到的HTML
                return BuildManager.CreateInstanceFromVirtualPath("~/Web/other/noFound.html", typeof(IHttpHandler)) as IHttpHandler;
            }
            //導向指定的HTML
            return BuildManager.CreateInstanceFromVirtualPath("~/Web/Template/" + htmlName, typeof(IHttpHandler)) as IHttpHandler;
        }
    }
    //Web/other目錄Html的自動Route
    public class WebOtherHtmlRoute : IRouteHandler
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            var routeData = requestContext.RouteData;
            //取出參數
            string htmlUrl = Convert.ToString(routeData.Values["htmlUrl"]);
            //檢查看看有無該Model對應的HTML?
            string htmlName = htmlUrl + ".html";
            if (!File.Exists(HostingEnvironment.MapPath("~/Web/other/" + htmlName)))
            {
                //導向至找不到的HTML
                return BuildManager.CreateInstanceFromVirtualPath("~/Web/other/noFound.html", typeof(IHttpHandler)) as IHttpHandler;
            }
            //導向指定的HTML
            return BuildManager.CreateInstanceFromVirtualPath("~/Web/other/" + htmlName, typeof(IHttpHandler)) as IHttpHandler;
        }
    }
    //Api目錄的ashx自動Route
    public class ApiRoute : IRouteHandler
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            var routeData = requestContext.RouteData;
            //取出參數
            string model = Convert.ToString(routeData.Values["model"]);
            string type = Convert.ToString(routeData.Values["type"]);

            HttpContext.Current.Items.Add("model", model);
            if (!string.IsNullOrEmpty(type))
            {
                HttpContext.Current.Items.Add("type", type);
            }

            //檢查看看有無該Model對應的ASHX?
            string ashxName = model + ".ashx";

            //找不到對應的ASHX
            if (!File.Exists(HostingEnvironment.MapPath("~/api/" + ashxName)))
            {
                return BuildManager.CreateInstanceFromVirtualPath("~/api/error.ashx", typeof(IHttpHandler)) as IHttpHandler;
            }
            //導向指定的ASHX
            return BuildManager.CreateInstanceFromVirtualPath("~/api/" + ashxName, typeof(IHttpHandler)) as IHttpHandler;
        }
    }
}