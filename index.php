<?php
require_once 'config.php';
require_once 'header.php';

$conn = getDBConnection();

// Get stats for dashboard
$stats = [];

// Total orders
$result = $conn->query("SELECT COUNT(*) as total_orders FROM Orders");
$stats['total_orders'] = $result->fetch_assoc()['total_orders'];

// Today's orders
$result = $conn->query("SELECT COUNT(*) as today_orders FROM Orders WHERE DATE(order_date) = CURDATE()");
$stats['today_orders'] = $result->fetch_assoc()['today_orders'];

// Total revenue
$result = $conn->query("SELECT SUM(total_amount) as total_revenue FROM Orders WHERE status = 'completed'");
$stats['total_revenue'] = $result->fetch_assoc()['total_revenue'] ?? 0;

// Active reservations
$result = $conn->query("SELECT COUNT(*) as active_reservations FROM Reservations WHERE status = 'confirmed' AND reservation_date >= CURDATE()");
$stats['active_reservations'] = $result->fetch_assoc()['active_reservations'];

// Recent orders
$result = $conn->query("SELECT o.order_id, o.order_date, c.first_name, c.last_name, o.total_amount, o.status 
                        FROM Orders o 
                        JOIN Customers c ON o.customer_id = c.customer_id 
                        ORDER BY o.order_date DESC LIMIT 5");
$recent_orders = $result->fetch_all(MYSQLI_ASSOC);

// Recent reservations
$result = $conn->query("SELECT r.reservation_id, r.reservation_date, r.start_time, c.first_name, c.last_name, r.party_size 
                        FROM Reservations r 
                        JOIN Customers c ON r.customer_id = c.customer_id 
                        WHERE r.reservation_date >= CURDATE() 
                        ORDER BY r.reservation_date, r.start_time ASC LIMIT 5");
$recent_reservations = $result->fetch_all(MYSQLI_ASSOC);

closeDBConnection($conn);
?>

<h2>Dashboard</h2>

<div class="stats-container">
    <div class="stat-card">
        <h3>Total Orders</h3>
        <div class="value"><?php echo $stats['total_orders']; ?></div>
    </div>
    
    <div class="stat-card">
        <h3>Today's Orders</h3>
        <div class="value"><?php echo $stats['today_orders']; ?></div>
    </div>
    
    <div class="stat-card">
        <h3>Total Revenue</h3>
        <div class="value">$<?php echo number_format($stats['total_revenue'], 2); ?></div>
    </div>
    
    <div class="stat-card">
        <h3>Active Reservations</h3>
        <div class="value"><?php echo $stats['active_reservations']; ?></div>
    </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px;">
    <div class="card">
        <div class="card-header">
            <h3>Recent Orders</h3>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Date</th>
                    <th>Customer</th>
                    <th>Amount</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($recent_orders as $order): ?>
                <tr>
                    <td><?php echo $order['order_id']; ?></td>
                    <td><?php echo date('M j, Y H:i', strtotime($order['order_date'])); ?></td>
                    <td><?php echo $order['first_name'] . ' ' . $order['last_name']; ?></td>
                    <td>$<?php echo number_format($order['total_amount'], 2); ?></td>
                    <td><?php echo ucfirst($order['status']); ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    
    <div class="card">
        <div class="card-header">
            <h3>Upcoming Reservations</h3>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Reservation ID</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Customer</th>
                    <th>Party Size</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($recent_reservations as $reservation): ?>
                <tr>
                    <td><?php echo $reservation['reservation_id']; ?></td>
                    <td><?php echo date('M j, Y', strtotime($reservation['reservation_date'])); ?></td>
                    <td><?php echo date('H:i', strtotime($reservation['start_time'])); ?></td>
                    <td><?php echo $reservation['first_name'] . ' ' . $reservation['last_name']; ?></td>
                    <td><?php echo $reservation['party_size']; ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once 'footer.php'; ?>