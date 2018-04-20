package spark;

import static spark.Spark.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sql2o.Connection;
import org.sql2o.Sql2o;

import spark.template.jtwig.JtwigTemplateEngine;

public class Application implements spark.servlet.SparkApplication {
	
    @Override
    public void init() {
    	
        get("/", (request, response) -> {
        	String jdbcURL = "jdbc:mysql://yhjung4.cmkcm6t8bgwe.ap-northeast-2.rds.amazonaws.com:3306/employees?useUnicode=true";
        	Sql2o sql = new Sql2o(jdbcURL, "", "");
        	List<Department> departments = null;
        	try(Connection conn = sql.open()){
        		departments = conn.createQuery("select * from departments").executeAndFetch(Department.class);
        	}
        	Map<String, Object> model = new HashMap<>();
            model.put("departments", departments);
            return new ModelAndView(model, "hello.twig");
        }, new JtwigTemplateEngine());

        get("/hello/:name", (request, response) -> {
            return "Hello: " + request.params(":name");
        });
    }
}