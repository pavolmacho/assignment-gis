using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Npgsql;
using Newtonsoft;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using GeoJSON.Net.Feature;
using System.Data;
using GeoJSON.Net.Geometry;
using Newtonsoft.Json.Serialization;
using System.Web.Script.Services;

namespace WebApplication1
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            List<string> st = new List<string>();
            st = connect();
            int i = 0;
            for (i=0;i<st.Count();i++) { 
                DropDownList1.Items.Add((i+1)+"."+st[i]);
            }
        }
        
        protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
        {
            

        }
        static public List<string> connect()
        {
            NpgsqlConnection conn = new NpgsqlConnection("Server=127.0.0.1;Port=5432;User Id=postgres;Password=;Database=Mapa");
            NpgsqlCommand cmd = new NpgsqlCommand("select name from planet_osm_polygon where name like 'okres%' order by name", conn);

            DataSet ds = new DataSet();
            NpgsqlDataAdapter da = new NpgsqlDataAdapter();
            da.SelectCommand = cmd;
            conn.Open();
            da.Fill(ds);
            List < string > s = new List<string>();
            NpgsqlDataReader reader = cmd.ExecuteReader();

            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                s.Add(dr["name"].ToString());
            }

            conn.Close();
            return s;
                        
        }
          
        [System.Web.Services.WebMethod]
        public static string GetDataSet(string x,string y)
        {
            NpgsqlConnection conn = new NpgsqlConnection("Server=127.0.0.1;Port=5432;User Id=postgres;Password=;Database=Mapa");
            NpgsqlDataAdapter da = new NpgsqlDataAdapter();
            NpgsqlCommand cmd = new NpgsqlCommand("SELECT row_to_json(fc) FROM(SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features FROM(SELECT 'Feature' As type , ST_AsGeoJSON(p.way)::json As geometry "+
            ", row_to_json((SELECT l FROM(SELECT p.dialka) As l)) As properties FROM(SELECT name, way, ST_Distance(ST_Transform(ST_GeomFromText('POINT(" + y + " " + x + ")', 4326), 26986), ST_Transform(way, 26986)) / 1000 as dialka " +
            "from planet_osm_polygon as p where p.natural = 'water' or landuse = 'reservoir' or waterway != '' order by dialka limit 3)As p) As f)  As fc; ",conn);
            da.SelectCommand = cmd;
            DataSet ds = new DataSet();
            conn.Open();
            da.Fill(ds);
            conn.Close();

            string s = null;
            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                s = dr["row_to_json"].ToString();
            }

            return s;
        }

        [System.Web.Services.WebMethod]
        public static string GetDataSet2(string okr)
        {
            NpgsqlConnection conn = new NpgsqlConnection("Server=127.0.0.1;Port=5432;User Id=postgres;Password=;Database=Mapa");
            NpgsqlDataAdapter da = new NpgsqlDataAdapter();
            NpgsqlCommand cmd = new NpgsqlCommand("select ST_AsGeoJson(way) as okres from planet_osm_line where admin_level = '8' and name = '"+okr+"'", conn);
            da.SelectCommand = cmd;
            DataSet ds = new DataSet();
            conn.Open();
            da.Fill(ds);
            conn.Close();
            string s = null;
            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                s = dr["okres"].ToString();
            }
            
            return s;
        }

        [System.Web.Services.WebMethod]
        public static string GetDataSet3(string okr)
        {
            
             NpgsqlConnection conn = new NpgsqlConnection("Server=127.0.0.1;Port=5432;User Id=postgres;Password=;Database=Mapa");
             NpgsqlDataAdapter da = new NpgsqlDataAdapter();
             NpgsqlCommand cmd2 = new NpgsqlCommand("Select ST_AsText(ST_MakePolygon((select ST_AsText(way) from planet_osm_line where admin_level = '8' and name = '"+okr+"')))", conn);
             string okres = null;
             conn.Open();
             NpgsqlDataReader reader = cmd2.ExecuteReader();
             if (reader.Read())
             {
                 okres = reader[0].ToString();
                 System.Diagnostics.Debug.WriteLine(okres);
                 conn.Close();
             }
             else
             {
                 conn.Close();
             }

             NpgsqlCommand cmd = new NpgsqlCommand("SELECT row_to_json(fc) FROM(SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features FROM(SELECT 'Feature' As type " +
              ", ST_AsGeoJSON(p.way)::json as geometry, row_to_json((SELECT l FROM(SELECT p.name) As l )) As properties FROM planet_osm_polygon As p Where(Select ST_Intersects((" +
              "@okres ), ((select ST_AsText(p.way) where p.natural = 'water' or landuse = 'reservoir' or waterway != ''))))= true ) As f )  As fc; ", conn);
             cmd.Parameters.AddWithValue("@okres",okres);
             da.SelectCommand = cmd;
             DataSet ds = new DataSet();
             conn.Open();
             string s = null;
            
            NpgsqlDataReader reader1 = cmd.ExecuteReader();
            
            if (reader1.Read())
            {
                s = reader1["row_to_json"].ToString();
                conn.Close();
            }
            else
            {
                
                conn.Close();
            }
            conn.Close();
            return s;
        }
        [System.Web.Services.WebMethod]
        public static string GetDataSet4(string x)
        {
            char[] delimiterChars = { '[', ',', ']'};
            string posit = x;
            string[] coord = posit.Split(delimiterChars);
            NpgsqlConnection conn = new NpgsqlConnection("Server=127.0.0.1;Port=5432;User Id=postgres;Password=;Database=Mapa");
            NpgsqlDataAdapter da = new NpgsqlDataAdapter();
            NpgsqlCommand cmd = new NpgsqlCommand("SELECT row_to_json(fc) FROM(SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features "+
            "FROM(SELECT 'Feature' As type , ST_AsGeoJSON(ST_Centroid(p.way))::json As geometry , row_to_json((SELECT l FROM(SELECT p.name) As l)) As properties FROM(select way, name "+
            "from planet_osm_polygon where ST_distance(ST_Transform((select ali.way from(SELECT way, ST_Distance(ST_Transform(ST_GeomFromText('POINT(" + coord[0] +" " + coord[1] + ")', 4326), 26986), ST_Transform(way, 26986)) / 1000 as dialka " +
            "from planet_osm_polygon as p where p.natural = 'water' or landuse = 'reservoir' or waterway != '' order by dialka limit 1) as ali), 26986), ST_Transform(way, 26986)) < 500 and amenity = 'parking')as p ) As f )  As fc; ", conn);
            da.SelectCommand = cmd;
            DataSet ds = new DataSet();
            conn.Open();
            string s = null;
            NpgsqlDataReader reader1 = cmd.ExecuteReader();

            if (reader1.Read())
            {
                s = reader1["row_to_json"].ToString();
                conn.Close();
            }
            else
            {
                conn.Close();                
            }
            conn.Close();
            return s;
        }
        protected void Button1_Click(object sender, EventArgs e)
        {
           
        }
    }
}