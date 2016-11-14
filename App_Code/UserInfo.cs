using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Compilation;
using System.Web.Hosting;
using System.Web.Routing;

/// <summary>
/// KaiNamespace 的摘要描述
/// </summary>


public static class UserInfo
{
    public static string UserID;
    public static bool loginValidation(HttpContext context)
    {
        bool check = false;
        if (context.Session != null)
        {
            string ip = context.Request.ServerVariables["REMOTE_ADDR"];
            if (ip.IndexOf("192.168") != -1)
            {
                check = true;
            }
            else if (ip.IndexOf("128.5.81") != -1)
            {
                if(Int32.Parse(ip.Split('.')[3])>=120 && Int32.Parse(ip.Split('.')[3]) <= 150)
                {
                    check = true;
                }               
            }
            else if (ip.IndexOf("127.0.0.1") != -1)
            {
                check = true;
            }
            if (context.Session["login"] != null && (bool)context.Session["login"])
            {
                check = true;
            }
            return check;
        }
        return check;
    }
}

