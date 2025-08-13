<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";	

    // Handle form submission for new measurements
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            int age = Integer.parseInt(request.getParameter("age"));
            float weight = Float.parseFloat(request.getParameter("weight"));
            float heightFt = Float.parseFloat(request.getParameter("height")); // height in feet
            float waist = Float.parseFloat(request.getParameter("waist"));

            // Convert feet to meters for BMI calculation
            float heightMeters = heightFt * 0.3048f;
            float bmi = weight / (heightMeters * heightMeters);

            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = "jdbc:mysql://localhost:3306/health_fitness_db";
            String dbUser = "root"; // your DB username
            String dbPass = "";     // your DB password

            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            String insertSql = "INSERT INTO measurements (user_id, age, weight, height, bmi, waist) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(insertSql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, age);
            pstmt.setFloat(3, weight);
            pstmt.setFloat(4, heightFt); // store feet in DB
            pstmt.setFloat(5, bmi);
            pstmt.setFloat(6, waist);

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                message = "Measurement saved successfully.";
            } else {
                message = "Failed to save measurement.";
            }

            pstmt.close();
            conn.close();

        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<html>
<head>
    <title>Dashboard</title>
    <link rel="stylesheet" href="style.css" />
</head>
<body>
<h2>Welcome to your Dashboard!</h2>
<p><a href="logout.jsp">Logout</a></p>
<p><a href="workouts.jsp">Workouts</a></p>

<h3>Enter New Measurement</h3>

<form method="post" action="dashboard.jsp">
    Age (years): <input type="number" name="age" required/><br/>
    Weight (kg): <input type="number" step="0.1" name="weight" required/><br/>
    Height (ft): <input type="number" step="0.01" name="height" required/><br/>
    Waist (cm): <input type="number" step="0.1" name="waist" required/><br/><br/>
    <input type="submit" value="Save Measurement"/>
</form>

<p style="color:green;"><%= message %></p>

<h3>Your Past Measurements</h3>

<table border="1" cellpadding="5" cellspacing="0">
    <tr>
        <th>Date</th>
        <th>Age (years)</th>
        <th>Weight (kg)</th>
        <th>Height (ft)</th>
        <th>BMI</th>
        <th>Waist (cm)</th>
    </tr>

    <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = "jdbc:mysql://localhost:3306/health_fitness_db";
            String dbUser = "root";
            String dbPass = "";

            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            String selectSql = "SELECT age, weight, height, bmi, waist, recorded_at FROM measurements WHERE user_id = ? ORDER BY recorded_at DESC";
            PreparedStatement pstmt = conn.prepareStatement(selectSql);
            pstmt.setInt(1, userId);

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
    %>
                <tr>
                    <td><%= rs.getTimestamp("recorded_at") %></td>
                    <td><%= rs.getInt("age") %></td>
                    <td><%= rs.getFloat("weight") %></td>
                    <td><%= rs.getFloat("height") %></td> <!-- height now in feet -->
                    <td><%= String.format("%.2f", rs.getFloat("bmi")) %></td>
                    <td><%= rs.getFloat("waist") %></td>
                </tr>
    <%
            }
            rs.close();
            pstmt.close();
            conn.close();

        } catch (Exception e) {
    %>
            <tr><td colspan="6" style="color:red;">Error loading measurements: <%= e.getMessage() %></td></tr>
    <%
        }
    %>
</table>

</body>
</html>
