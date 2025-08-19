<?php
require_once 'config.php';
require_once 'header.php';

if(!isset($_GET['id'])) {
    header("Location: orders.php");
    exit();
}

$order_id = $_GET['id'];
$conn = getDBConnection();

// Get order details
$stmt = $conn->prepare("SELECT o.*, c.first_name, c.last_name, c.phone_number, c.email, 
                        u.first_name as staff_first, u.last_name as staff_last
                        FROM Orders o
                        LEFT JOIN Customers c ON o.customer_id = c.customer_id
                        LEFT JOIN Users u ON o.user_id = u.user_id
                        WHERE o.order_id = ?");
$stmt->bind_param("i", $order_id);
$stmt->execute();
$order = $stmt->get_result()->fetch_assoc();
$stmt->close();

// Get order items
$stmt = $conn->prepare("SELECT oi.*, mi.item_name, mi.description 
                        FROM OrderItems oi
                        JOIN MenuItems mi ON oi.item_id = mi.item_id
                        WHERE oi.order_id = ?");
$stmt->bind_param("i", $order_id);
$stmt->execute();
$order_items = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();

// Get payment details
$stmt = $conn->prepare("SELECT * FROM Payments WHERE order_id = ?");
$stmt->bind_param("i", $order_id);
$stmt->execute();
$payment = $stmt->get_result()->fetch_assoc();
$stmt->close();

closeDBConnection($conn);

if(!$order) {
    header("Location: orders.php");
    exit();
}
?>

<h2>Order Details #<?php echo $order_id; ?></h2>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
    <div class="card">
        <div class="card-header">
            <h3>Customer Information</h3>
        </div>
        <div style="padding: 20px;">
            <p><strong>Name:</strong> <?php echo $order['first_name'] . ' ' . $order['last_name']; ?></p>
            <p><strong>Phone:</strong> <?php echo $order['phone_number']; ?></p>
            <p><strong>Email:</strong> <?php echo $order['email'] ? $order['email'] : 'N/A'; ?></p>
        </div>
    </div>
    
    <div class="card">
        <div class="card-header">
            <h3>Order Information</h3>
        </div>
        <div style="padding: 20px;">
            <p><strong>Order Date:</strong> <?php echo date('M j, Y H:i', strtotime($order['order_date'])); ?></p>
            <p><strong>Order Type:</strong> <?php echo ucfirst($order['order_type']); ?></p>
            <p><strong>Status:</strong> <?php echo ucfirst($order['status']); ?></p>
            <p><strong>Staff:</strong> <?php echo isset($order['staff_first']) ? $order['staff_first'] . ' ' . $order['staff_last'] : 'N/A'; ?></p>
            <p><strong>Notes:</strong> <?php echo $order['notes'] ? $order['notes'] : 'N/A'; ?></p>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h3>Order Items</h3>
    </div>
    <table>
        <thead>
            <tr>
                <th>Item</th>
                <th>Description</th>
                <th>Quantity</th>
                <th>Price</th>
                <th>Total</th>
                <th>Special Instructions</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach($order_items as $item): ?>
            <tr>
                <td><?php echo $item['item_name']; ?></td>
                <td><?php echo $item['description']; ?></td>
                <td><?php echo $item['quantity']; ?></td>
                <td>$<?php echo number_format($item['item_price'], 2); ?></td>
                <td>$<?php echo number_format($item['item_price'] * $item['quantity'], 2); ?></td>
                <td><?php echo $item['special_instructions'] ? $item['special_instructions'] : 'N/A'; ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="3"></td>
                <td><strong>Subtotal:</strong></td>
                <td>$<?php echo number_format($order['total_amount'] - $order['tax_amount'] + $order['discount_amount'], 2); ?></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="3"></td>
                <td><strong>Tax:</strong></td>
                <td>$<?php echo number_format($order['tax_amount'], 2); ?></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="3"></td>
                <td><strong>Discount:</strong></td>
                <td>-$<?php echo number_format($order['discount_amount'], 2); ?></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="3"></td>
                <td><strong>Total:</strong></td>
                <td>$<?php echo number_format($order['total_amount'], 2); ?></td>
                <td></td>
            </tr>
        </tfoot>
    </table>
</div>

<?php if($payment): ?>
<div class="card">
    <div class="card-header">
        <h3>Payment Information</h3>
    </div>
    <div style="padding: 20px;">
        <p><strong>Payment Date:</strong> <?php echo date('M j, Y H:i', strtotime($payment['payment_date'])); ?></p>
        <p><strong>Amount:</strong> $<?php echo number_format($payment['amount'], 2); ?></p>
        <p><strong>Payment Method:</strong> <?php echo ucfirst(str_replace('_', ' ', $payment['payment_method'])); ?></p>
        <p><strong>Status:</strong> <?php echo ucfirst($payment['payment_status']); ?></p>
        <p><strong>Tip:</strong> $<?php echo number_format($payment['tip_amount'], 2); ?></p>
    </div>
</div>
<?php endif; ?>

<div style="text-align: center; margin-top: 20px;">
    <a href="orders.php" class="btn">Back to Orders</a>
</div>

<?php require_once 'footer.php'; ?>