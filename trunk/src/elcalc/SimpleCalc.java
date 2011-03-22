package elcalc;


import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import elcalc.battle.*;
import elcalc.battle.bean.*;
import java.util.HashMap;


public class SimpleCalc extends HttpServlet
{
    private String VERSION = "0.1";
    private String base_value = "";
    private BaseValue bv = null;

    public void doPost( HttpServletRequest req, HttpServletResponse res ) throws IOException
    {
        this.doCalc(req,res);
    }


    public boolean doCalc(HttpServletRequest req, HttpServletResponse res )
    {
        boolean result = false;
        this.bv =  new BaseValue(req,res);
        this.base_value = this.bv.calc();

        return result;
    }

    public String getVersion()
    {
        return VERSION;
    }

    public String getBaseValue()
    {
        return this.base_value;
    }

    public String getPs()
    {
        return this.bv.getPs();
    }
}
