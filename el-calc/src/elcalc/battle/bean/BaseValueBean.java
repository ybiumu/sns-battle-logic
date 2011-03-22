package elcalc.battle.bean;

import java.util.logging.Logger;

public class BaseValueBean
{
    private String ps = "0";
    private String sr = "0";
    private String main_expr = "0";
    private String sub_expr = "0";
    private String expr_type = "0";
    private String range = "1.0";
    private String rand = "0";

    private  Logger logger = Logger.getLogger(this.getClass().getName());
    /**
     *
     * @param rand
     */
    public void setRand( String rand )
    {
        this.rand = rand;
    }

    /**
     *
     * @return rand
     */
    public String getRand()
    {
        return this.rand;
    }

    public int getIntRand()
    {
        return Integer.parseInt(this.rand);
    }


    /**
     *
     * @param range
     */
    public void setRange( String range )
    {
        this.range = range;
    }

    /**
     *
     * @return range
     */
    public String getRange()
    {
        return this.range;
    }

    public int getIntRange()
    {
        int i = 1;
        try 
        {
           i = (int)Float.parseFloat( this.range );
        }
        catch(Exception e)
        {
            logger.warning("Class cast Exception ");
        }
        return i;
    }
    

    /**
     *
     * @param expr_type
     */
    public void setExprType( String expr_type )
    {
        this.expr_type = expr_type;
    }

    /**
     *
     * @return expr_type
     */
    public String getExprType()
    {
        return this.expr_type;
    }

    /**
     *
     * @param sub_expr
     */
    public void setSubExpr( String sub_expr )
    {
        this.sub_expr = sub_expr;
    }

    /**
     *
     * @return sub_expr
     */
    public String getSubExpr()
    {
        return this.sub_expr;
    }

    public float getFloatSubExpr()
    {
        return Float.parseFloat(this.sub_expr);
    }


    /**
     *
     * @param main_expr
     */
    public void setMainExpr( String main_expr )
    {
        this.main_expr = main_expr;
    }

    /**
     *
     * @return main_expr
     */
    public String getMainExpr()
    {
        return this.main_expr;
    }

    public float getFloatMainExpr()
    {
        return Float.parseFloat(this.main_expr);
    }




    /**
     *
     * @param sr
     */
    public void setSr( String sr )
    {
        this.sr = sr;
    }

    /**
     *
     * @param sr
     */
    public void setSr( String sr, String def )
    {
        if ( sr == null ) sr = def; 
        this.setSr( sr );
    }

    /**
     *
     * @return sr
     */
    public String getSr()
    {
        return this.sr;
    }

    public int getIntSr()
    {
        int i = 1;
        try 
        {
           i = (int)Float.parseFloat( this.sr );
        }
        catch(Exception e)
        {
            logger.warning("Class cast Exception ");
        }
        return i;
    }


    /**
     *
     * @param ps
     */
    public void setPs( String ps )
    {
        this.ps = ps;
    }



    /**
     *
     * @param ps
     */
    public void setPs( String ps , String def )
    {
        if ( ps == null ) ps = def;
        this.setPs( ps );
    }




    /**
     *
     * @return ps
     */
    public String getPs()
    {
        return this.ps;
    }


    public int getIntPs()
    {
        int i = 1;
        try 
        {
           i = (int)Float.parseFloat( this.ps );
        }
        catch(Exception e)
        {
            logger.warning("Class cast Exception ");
        }
        return i;
    }
}
