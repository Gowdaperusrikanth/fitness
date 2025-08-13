<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>User Login</title>
    <link rel="stylesheet" href="style.css" />
    
</head>
<body>
<h2>Login</h2>

<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
            message = "Please fill both username and password!";
        } else {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String dbUrl = "jdbc:mysql://localhost:3306/health_fitness_db";
                String dbUser = "root"; // your DB username
                String dbPass = "";     // your DB password

                conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                String query = "SELECT id FROM users WHERE username = ? AND password = ?";
                pstmt = conn.prepareStatement(query);
                pstmt.setString(1, username);
                pstmt.setString(2, password); // In real apps, compare hashed passwords

                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // Login successful - save user id in session
                    session.setAttribute("userId", rs.getInt("id"));
                    response.sendRedirect("dashboard.jsp");
                    return;
                } else {
                    message = "Invalid username or password!";
                }

            } catch (Exception e) {
                message = "Error: " + e.getMessage();
            } finally {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        }
    }
%>

<form method="post" action="login.jsp">
    Username:<br/>
    <input type="text" name="username" /><br/>
    Password:<br/>
    <input type="password" name="password" /><br/><br/>
    <input type="submit" value="Login" />
</form>

<p style="color:red;"><%= message %></p>

<p>Don't have an account? <a href="register.jsp">Register here</a>.</p>

</body>
</html>
