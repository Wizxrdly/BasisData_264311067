SELECT 
    pl.nama_lengkap AS nama_pelanggan,
    COUNT(ps.order_id) AS total_transaksi,
    SUM(ps.total_harga) AS total_nominal_belanja
FROM pelanggan pl
JOIN pesanan ps ON pl.customer_id = ps.customer_id
WHERE ps.status_pesanan = 'Selesai'
GROUP BY pl.customer_id, pl.nama_lengkap;
