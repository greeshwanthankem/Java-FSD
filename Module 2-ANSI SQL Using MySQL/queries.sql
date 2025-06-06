-- =============== TABLE CREATION ===============

CREATE TABLE Users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  city VARCHAR(100) NOT NULL,
  registration_date DATE NOT NULL
);

CREATE TABLE Events (
  event_id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  city VARCHAR(100) NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  status ENUM('upcoming','completed','cancelled'),
  organizer_id INT,
  FOREIGN KEY (organizer_id) REFERENCES Users(user_id)
);

CREATE TABLE Sessions (
  session_id INT PRIMARY KEY AUTO_INCREMENT,
  event_id INT,
  title VARCHAR(200) NOT NULL,
  speaker_name VARCHAR(100) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

CREATE TABLE Registrations (
  registration_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  event_id INT,
  registration_date DATE NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users(user_id),
  FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

CREATE TABLE Feedback (
  feedback_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  event_id INT,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  comments TEXT,
  feedback_date DATE NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users(user_id),
  FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

CREATE TABLE Resources (
  resource_id INT PRIMARY KEY AUTO_INCREMENT,
  event_id INT,
  resource_type ENUM('pdf','image','link'),
  resource_url VARCHAR(255) NOT NULL,
  uploaded_at DATETIME NOT NULL,
  FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- =============== EXERCISES & SAMPLE SOLUTIONS ===============

-- 1. Show a list of all upcoming events a user is registered for in their city, sorted by date.
SELECT E.*
FROM Events E
JOIN Registrations R ON E.event_id = R.event_id
JOIN Users U ON R.user_id = U.user_id
WHERE U.user_id = 1 AND E.city = U.city AND E.status = 'upcoming'
ORDER BY E.start_date;

-- 2. Identify events with the highest average rating, considering only those that have received at least 10 feedback submissions.
SELECT event_id, AVG(rating) AS avg_rating
FROM Feedback
GROUP BY event_id
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC;

-- 3. Retrieve users who have not registered for any events in the last 90 days.
SELECT *
FROM Users
WHERE user_id NOT IN (
  SELECT user_id FROM Registrations
  WHERE registration_date >= CURDATE() - INTERVAL 90 DAY
);

-- 4. Count how many sessions are scheduled between 10 AM to 12 PM for each event.
SELECT event_id, COUNT(*) AS session_count
FROM Sessions
WHERE TIME(start_time) >= '10:00:00' AND TIME(end_time) <= '12:00:00'
GROUP BY event_id;

-- 5. List the top 5 cities with the highest number of distinct user registrations.
SELECT city, COUNT(DISTINCT user_id) AS num_users
FROM Users
GROUP BY city
ORDER BY num_users DESC
LIMIT 5;

-- 6. Generate a report showing the number of resources (PDFs, images, links) uploaded for each event.
SELECT event_id,
  SUM(resource_type='pdf') AS pdfs,
  SUM(resource_type='image') AS images,
  SUM(resource_type='link') AS links
FROM Resources
GROUP BY event_id;

-- 7. List all users who gave feedback with a rating less than 3, along with their comments and associated event names.
SELECT U.full_name, F.comments, E.title
FROM Feedback F
JOIN Users U ON F.user_id = U.user_id
JOIN Events E ON F.event_id = E.event_id
WHERE F.rating < 3;

-- 8. Display all upcoming events with the count of sessions scheduled for them.
SELECT E.event_id, E.title, COUNT(S.session_id) AS session_count
FROM Events E
LEFT JOIN Sessions S ON E.event_id = S.event_id
WHERE E.status = 'upcoming'
GROUP BY E.event_id, E.title;

-- 9. For each event organizer, show the number of events created and their current status (upcoming, completed, cancelled).
SELECT U.full_name, E.status, COUNT(*) AS event_count
FROM Events E
JOIN Users U ON E.organizer_id = U.user_id
GROUP BY U.full_name, E.status;

-- 10. Identify events that had registrations but received no feedback at all.
SELECT E.event_id, E.title
FROM Events E
JOIN Registrations R ON E.event_id = R.event_id
LEFT JOIN Feedback F ON E.event_id = F.event_id
WHERE F.event_id IS NULL
GROUP BY E.event_id, E.title;

-- 11. Find the number of users who registered each day in the last 7 days.
SELECT registration_date, COUNT(*) AS user_count
FROM Users
WHERE registration_date >= CURDATE() - INTERVAL 7 DAY
GROUP BY registration_date;

-- 12. List the event(s) with the highest number of sessions.
SELECT event_id, COUNT(*) AS session_count
FROM Sessions
GROUP BY event_id
HAVING session_count = (
  SELECT MAX(session_total)
  FROM (
    SELECT COUNT(*) AS session_total
    FROM Sessions
    GROUP BY event_id
  ) AS counts
);

-- 13. Calculate the average feedback rating of events conducted in each city.
SELECT E.city, AVG(F.rating) AS avg_rating
FROM Events E
JOIN Feedback F ON E.event_id = F.event_id
GROUP BY E.city;

-- 14. List top 3 events based on the total number of user registrations.
SELECT E.event_id, E.title, COUNT(R.registration_id) AS total_registrations
FROM Events E
JOIN Registrations R ON E.event_id = R.event_id
GROUP BY E.event_id, E.title
ORDER BY total_registrations DESC
LIMIT 3;

-- 15. Identify overlapping sessions within the same event (i.e., session start and end times that conflict).
SELECT S1.event_id, S1.session_id AS session1, S2.session_id AS session2
FROM Sessions S1
JOIN Sessions S2
  ON S1.event_id = S2.event_id
 AND S1.session_id < S2.session_id
 AND S1.end_time > S2.start_time
 AND S1.start_time < S2.end_time;

-- 16. Find users who created an account in the last 30 days but haven’t registered for any events.
SELECT *
FROM Users U
WHERE registration_date >= CURDATE() - INTERVAL 30 DAY
AND NOT EXISTS (
  SELECT 1 FROM Registrations R WHERE R.user_id = U.user_id
);

-- 17. Identify speakers who are handling more than one session across all events.
SELECT speaker_name, COUNT(*) AS session_count
FROM Sessions
GROUP BY speaker_name
HAVING session_count > 1;

-- 18. List all events that do not have any resources uploaded.
SELECT E.event_id, E.title
FROM Events E
LEFT JOIN Resources R ON E.event_id = R.event_id
WHERE R.resource_id IS NULL;

-- 19. For completed events, show total registrations and average feedback rating.
SELECT E.event_id, E.title, COUNT(DISTINCT R.registration_id) AS total_registrations, AVG(F.rating) AS avg_rating
FROM Events E
LEFT JOIN Registrations R ON E.event_id = R.event_id
LEFT JOIN Feedback F ON E.event_id = F.event_id
WHERE E.status = 'completed'
GROUP BY E.event_id, E.title;

-- 20. For each user, calculate how many events they attended and how many feedbacks they submitted.
SELECT U.user_id, U.full_name,
  COUNT(DISTINCT R.event_id) AS events_attended,
  COUNT(DISTINCT F.feedback_id) AS feedbacks_submitted
FROM Users U
LEFT JOIN Registrations R ON U.user_id = R.user_id
LEFT JOIN Feedback F ON U.user_id = F.user_id
GROUP BY U.user_id, U.full_name;

-- 21. List top 5 users who have submitted the most feedback entries.
SELECT U.user_id, U.full_name, COUNT(F.feedback_id) AS feedback_count
FROM Feedback F
JOIN Users U ON F.user_id = U.user_id
GROUP BY U.user_id, U.full_name
ORDER BY feedback_count DESC
LIMIT 5;

-- 22. Detect if a user has been registered more than once for the same event.
SELECT user_id, event_id, COUNT(*) AS registration_count
FROM Registrations
GROUP BY user_id, event_id
HAVING registration_count > 1;

-- 23. Show a month-wise registration count trend over the past 12 months.
SELECT DATE_FORMAT(registration_date, '%Y-%m') AS month, COUNT(*) AS registration_count
FROM Registrations
WHERE registration_date >= CURDATE() - INTERVAL 12 MONTH
GROUP BY month
ORDER BY month;

-- 24. Compute the average duration (in minutes) of sessions in each event.
SELECT event_id,
  AVG(TIMESTAMPDIFF(MINUTE, start_time, end_time)) AS avg_duration_minutes
FROM Sessions
GROUP BY event_id;

-- 25. List all events that currently have no sessions scheduled under them.
SELECT E.event_id, E.title
FROM Events E
LEFT JOIN Sessions S ON E.event_id = S.event_id
WHERE S.session_id IS NULL;

-- ================= END =================
