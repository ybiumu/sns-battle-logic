package elcalc.battle;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.HashMap;
import elcalc.battle.bean.BaseValueBean;


public class BaseValue extends BaseValueBean
{
    protected final String CALC_FORMAT = "#######.##";
    protected static final HashMap<String,String> RANGE_MAP = new HashMap<String,String>();
    protected static final HashMap<String,Integer> RAND_ALIAS = new HashMap<String,Integer>();
    protected static final HashMap<String,int[]> RAND_MAP = new HashMap<String,int[]>();

    protected final String PS_DEFAULT = "0";
    protected final String SR_DEFAULT = "0";
    protected final String MAIN_EXPR_DEFAULT = "0";
    protected final String SUB_EXPR_DEFAULT = "0";

    static {
        RANGE_MAP.put("short",  "1.0");
        RANGE_MAP.put("middle", "0.9");
        RANGE_MAP.put("long",   "0.8");

        RAND_ALIAS.put("a", 0);
        RAND_ALIAS.put("b", 5);
        RAND_ALIAS.put("c", 10);
        RAND_ALIAS.put("d", 25);
        RAND_ALIAS.put("e", 50);
        RAND_ALIAS.put("f",100);

        int[] r0  = {0};
        RAND_MAP.put( "0", r0 );
        int[] r5  = {
            -5, -4,-3,-2,-1,
            0,
            1, 2, 3, 4, 5
            };
        RAND_MAP.put( "5",  r5 );
        int[] r10 = {
            -10,-9,-8,-7,-6,
            -5, -4,-3,-2,-1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9,10
            };
        RAND_MAP.put( "10", r10 );
        int[] r20 = {
            -20,-19,-18,-17,-16,
            -15,-14,-13,-12,-11,
            -10,-9,-8,-7,-6,
            -5, -4,-3,-2,-1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9,10,
            11,12,13,14,15,
            16,17,18,19,20
            };
        RAND_MAP.put( "20",  r20 );
        int[] r25 = {
            -25, -24,-23, -22,-21,
            -20, -19,-18, -17,-16,
            -15, -14,-13, -12,-11,
            -10,  -9, -8,  -7,-6,
            -5,   -4, -3,  -2,-1,
            0,
            1,  2,  3,  4,  5,
            6,  7,  8,  9,  10,
            11, 12, 13, 14, 15,
            16, 17, 18, 19, 20,
            21, 22, 23, 24, 25
            };
        RAND_MAP.put( "25",  r25 );
        int[] r50 = {
            -50, -49, -48, -47, -46,
            -45, -44, -43, -42, -41,
            -40, -39, -38, -37, -36,
            -35, -34, -33, -32, -31,
            -30, -29, -28, -27, -26,
            -25, -24, -23, -22, -21,
            -20, -19, -18, -17, -16,
            -15, -14, -13, -12, -11,
            -10, -9, -8, -7, -6,
            -5, -4, -3, -2, -1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9, 10,
            11, 12, 13, 14, 15,
            16, 17, 18, 19, 20,
            21, 22, 23, 24, 25,
            26, 27, 28, 29, 30,
            31, 32, 33, 34, 35,
            36, 37, 38, 39, 40,
            41, 42, 43, 44, 45,
            46, 47, 48, 49, 50
            };
        RAND_MAP.put( "50",  r50 );
        int[] r100 = {
            -100, -99, -98, -97, -96,
            -95, -94, -93, -92, -91,
            -90, -89, -88, -87, -86,
            -85, -84, -83, -82, -81,
            -80, -79, -78, -77, -76,
            -75, -74, -73, -72, -71,
            -70, -69, -68, -67, -66,
            -65, -64, -63, -62, -61,
            -60, -59, -58, -57, -56,
            -55, -54, -53, -52, -51,
            -50, -49, -48, -47, -46,
            -45, -44, -43, -42, -41,
            -40, -39, -38, -37, -36,
            -35, -34, -33, -32, -31,
            -30, -29, -28, -27, -26,
            -25, -24, -23, -22, -21,
            -20, -19, -18, -17, -16,
            -15, -14, -13, -12, -11,
            -10, -9, -8, -7, -6,
            -5, -4, -3, -2, -1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9, 10,
            11, 12, 13, 14, 15,
            16, 17, 18, 19, 20,
            21, 22, 23, 24, 25,
            26, 27, 28, 29, 30,
            31, 32, 33, 34, 35,
            36, 37, 38, 39, 40,
            41, 42, 43, 44, 45,
            46, 47, 48, 49, 50,
            51, 52, 53, 54, 55,
            56, 57, 58, 59, 60,
            61, 62, 63, 64, 65,
            66, 67, 68, 69, 70,
            71, 72, 73, 74, 75,
            76, 77, 78, 79, 80,
            81, 82, 83, 84, 85,
            86, 87, 88, 89, 90,
            91, 92, 93, 94, 95,
            96, 97, 98, 99, 100
            };
        RAND_MAP.put( "100", r100 );
    }




    public BaseValue( HttpServletRequest req, HttpServletResponse res )
    {
        this.init(req,res);
    }

    private void init( HttpServletRequest req, HttpServletResponse res )
    {
        this.setPs( req.getParameter("ps"),  PS_DEFAULT );
        this.setPs( req.getParameter("sr"),  SR_DEFAULT );
        this.setPs( req.getParameter("main_expr"),  MAIN_EXPR_DEFAULT );
        this.setPs( req.getParameter("sub_expr"),   SUB_EXPR_DEFAULT );
    }


    public String calc()
    {
        float val =  this.getIntPs() * this.getIntSr() * this.getExpRate() * this.getIntRange() * this.getRandMap();
        return ""+val;
//        String ret_val = sprintf(CALC_FORMAT, $class->getPs() * $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandMap());
    }





    public int getRandMap()
    {
        return (int)( (100 + ((int[])RAND_MAP.get(this.getRand()))[ rand( this.getIntRand()*2+1 ) ] ) / 100);
    }


    public int  getExpRate()
    {
        double exp_rate = 1.0;
        String type = this.getExprType();
        if ( type.equals("1") )
        {
            exp_rate = Math.sqrt( ( this.getFloatMainExpr()+100)/100 );
        }
        else if( type.equals("2") || type.equals("4") )
        {
            exp_rate = Math.sqrt( ( 2 * this.getFloatMainExpr() + this.getFloatSubExpr() + 200) / 200 );
        }
        else if( type.equals("3") )
        {
            exp_rate = Math.sqrt(  ( ( this.getFloatMainExpr() + this.getFloatSubExpr()) * 3 + 400) / 400 );
        }
        // logServlet.warn ("[EXP_RATE] "+exp_rate);
        return (int)exp_rate;
    }


    private int rand( int seed )
    {
        return (int)(Math.random() * seed);
    }


}
