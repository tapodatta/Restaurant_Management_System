<?php
require_once 'config.php';
require_once 'header.php';

$conn = getDBConnection();

// Handle order status update
if($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update_status'])) {
    $order_id = $_POST['order_id'];
    $new_status = $_POST['new_status'];
    
    $stmt = $conn->prepare("UPDATE Orders SET status = ? WHERE order_id = ?");
    $stmt->bind_param("si", $new_status, $order_id);
    
    if($stmt->execute()) {
        $success = "Order status updated successfully!";
    } else {
        $error = "Error updating order status: " . $stmt->error;
    }
    
    $stmt->close();
}

// Get all orders
$query = "SELECT o.order_id, o.order_date, c.first_name, c.last_name, o.total_amount, o.status, o.order_type, 
                 u.first_name as staff_first, u.last_name as staff_last
          FROM Orders o
          LEFT JOIN Customers c ON o.customer_id = c.customer_id
          LEFT JOIN Users u ON o.user_id = u.user_id
          ORDER BY o.order_date DESC";
          
$result = $conn->query($query);
$orders = $result->fetch_all(MYSQLI_ASSOC);

closeDBConnection($conn);
?>

<h2>Order Management</h2>

<?php if(isset($success)): ?>
    <div style="color: green; margin-bottom: 15px;"><?php echo $success; ?></div>
<?php endif; ?>

<?php if(isset($error)): ?>
    <div style="color: red; margin-bottom: 15px;"><?php echo $error; ?></div>
<?php endif; ?>

<div class="card">
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Date/Time</th>
                <th>Customer</th>
                <th>Staff</th>
                <th>Type</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach($orders as $order): ?>
            <tr>
                <td><?php echo $order['order_id']; ?></td>
                <td><?php echo date('M j, Y H:i', strtotime($order['order_date'])); ?></td>
                <td><?php echo $order['first_name'] . ' ' . $order['last_name']; ?></td>
                <td><?php echo isset($order['staff_first']) ? $order['staff_first'] . ' ' . $order['staff_last'] : 'N/A'; ?></td>
                <td><?php echo ucfirst($order['order_type']); ?></td>
                <td>$<?php echo number_format($order['total_amount'], 2); ?></td>
                <td><?php echo ucfirst($order['status']); ?></td>
                <td>
                    <form method="POST" action="orders.php" style="display: inline;">
                        <input type="hidden" name="order_id" value="<?php echo $order['order_id']; ?>">
                        <select name="new_status" onchange="this.form.submit()">
                            <option value="pending" <?php echo $order['status'] == 'pending' ? 'selected' : ''; ?>>Pending</option>
                            <option value="preparing" <?php echo $order['status'] == 'preparing' ? 'selected' : ''; ?>>Preparing</option>
                            <option value="ready" <?php echo $order['status'] == 'ready' ? 'selected' : ''; ?>>Ready</option>
                            <option value="served" <?php echo $order['status'] == 'served' ? 'selected' : ''; ?>>Served</option>
                            <option value="completed" <?php echo $order['status'] == 'completed' ? 'selected' : ''; ?>>Completed</option>
                            <option value="cancelled" <?php echo $order['status'] == 'cancelled' ? 'selected' : ''; ?>>Cancelled</option>
                        </select>
                        <input type="hidden" name="update_status" value="1">
                    </form>
                    <a href="order_details.php?id=<?php echo $order['order_id']; ?>" class="btn">Details</a>
                </td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

<?php require_once 'footer.php'; ?>