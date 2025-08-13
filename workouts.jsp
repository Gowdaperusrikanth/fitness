<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";

    // Calorie burn rates per minute for each workout type
    java.util.Map<String, Double> calorieRates = new java.util.HashMap<>();
    calorieRates.put("Running", 10.0);   // calories per minute
    calorieRates.put("Cycling", 8.5);
    calorieRates.put("Walking", 4.5);
    calorieRates.put("Swimming", 9.0);
    calorieRates.put("Yoga", 3.0);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            String workoutType = request.getParameter("workout_type");
            int duration = Integer.parseInt(request.getParameter("duration"));
            String workoutDate = request.getParameter("workout_date");

            // Default rate if workout type is not in map
            double rate = calorieRates.getOrDefault(workoutType, 5.0);
            int calories = (int) Math.round(rate * duration);

            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = "jdbc:mysql://localhost:3306/health_fitness_db";
            String dbUser = "root"; // your DB username
            String dbPass = "";     // your DB password

            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            String insertSql = "INSERT INTO workouts (user_id, workout_type, duration_minutes, calories_burned, workout_date) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(insertSql);
            pstmt.setInt(1, userId);
            pstmt.setString(2, workoutType);
            pstmt.setInt(3, duration);
            pstmt.setInt(4, calories);
            pstmt.setDate(5, java.sql.Date.valueOf(workoutDate));

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                message = "Workout logged successfully. Calories Burned: " + calories;
            } else {
                message = "Failed to log workout.";
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
    <title>Workout Log</title>
    <link rel="stylesheet" href="style.css" />
</head>
<body>
<h2>Workout Log</h2>
<p><a href="dashboard.jsp">Dashboard</a> | <a href="logout.jsp">Logout</a></p>

<form method="post" action="workouts.jsp">
    Workout Type:<br/>
    <select name="workout_type" required>
        <option value="">--Select--</option>
        <option>Running</option>
        <option>Cycling</option>
        <option>Walking</option>
        <option>Swimming</option>
        <option>Yoga</option>
    </select><br/>
    Duration (minutes):<br/>
    <input type="number" name="duration" min="1" required /><br/>
    Workout Date:<br/>
    <input type="date" name="workout_date" value="<%=java.time.LocalDate.now()%>" required /><br/><br/>
    <input type="submit" value="Log Workout" />
</form>

<p style="color:green;"><%= message %></p>

<h3>Your Past Workouts</h3>

<table border="1" cellpadding="5" cellspacing="0">
    <tr>
        <th>Date</th>
        <th>Workout Type</th>
        <th>Duration (min)</th>
        <th>Calories Burned</th>
    </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String dbUrl = "jdbc:mysql://localhost:3306/health_fitness_db";
        String dbUser = "root";
        String dbPass = "";

        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String selectSql = "SELECT workout_date, workout_type, duration_minutes, calories_burned FROM workouts WHERE user_id = ? ORDER BY workout_date DESC";
        PreparedStatement pstmt = conn.prepareStatement(selectSql);
        pstmt.setInt(1, userId);

        ResultSet rs = pstmt.executeQuery();

        while(rs.next()) {
%>
    <tr>
        <td><%= rs.getDate("workout_date") %></td>
        <td><%= rs.getString("workout_type") %></td>
        <td><%= rs.getInt("duration_minutes") %></td>
        <td><%= rs.getInt("calories_burned") %></td>
    </tr>
<%
        }

        rs.close();
        pstmt.close();
        conn.close();
    } catch(Exception e) {
%>
    <tr><td colspan="4" style="color:red;">Error loading workouts: <%= e.getMessage() %></td></tr>
<%
    }
%>

</table>

</body>
</html>
