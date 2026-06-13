-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 12, 2026 at 10:26 AM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 7.4.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `edu_platform`
--

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` int(10) UNSIGNED NOT NULL,
  `teacher_id` int(10) UNSIGNED NOT NULL,
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `upload_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`id`, `teacher_id`, `file_path`, `description`, `upload_date`) VALUES
(1, 7, 'uploads/documents/299bae799eea24cff61905868a5eec89.txt', '', '2026-06-02 08:51:12');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `sender_id` int(10) UNSIGNED NOT NULL,
  `receiver_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '''all'' or a user id',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('private','public') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'private',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `sender_id`, `receiver_id`, `content`, `type`, `timestamp`) VALUES
(1, 1, 'all', 'oui', 'public', '2026-04-24 08:37:38'),
(3, 7, '6', 'ya amin a9ra 3ala ro7k', 'private', '2026-06-02 08:50:52');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `product_name`, `price`, `stock_quantity`) VALUES
(1, 'Mathematics Textbook', '29.99', 5),
(2, 'Physics Workbook', '19.99', 15),
(3, 'Chemistry Lab Guide', '34.50', 10),
(4, 'Biology Atlas', '45.00', 30),
(5, 'History Compendium', '22.00', 50),
(6, 'Literature Anthology', '18.75', 25),
(7, 'Programming Handbook', '55.00', 8),
(8, 'Art & Design Manual', '40.00', 20),
(9, 'Mathematics Textbook', '29.99', 5),
(10, 'Physics Workbook', '19.99', 15),
(11, 'Chemistry Lab Guide', '34.50', 10),
(12, 'Biology Atlas', '45.00', 30),
(13, 'History Compendium', '22.00', 50),
(14, 'Literature Anthology', '18.75', 25),
(15, 'Programming Handbook', '55.00', 8),
(16, 'Art & Design Manual', '40.00', 20),
(17, 'Mathematics Textbook', '29.99', 5),
(18, 'Physics Workbook', '19.99', 15),
(19, 'Chemistry Lab Guide', '34.50', 10),
(20, 'Biology Atlas', '45.00', 30),
(21, 'History Compendium', '22.00', 50),
(22, 'Literature Anthology', '18.75', 25),
(23, 'Programming Handbook', '55.00', 8),
(24, 'Art & Design Manual', '40.00', 20);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `full_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','teacher','student') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'Administrator', 'admin@gmail.com', '$2y$12$/vb02R0G2WD7H0z8tiIn6ebWrkiPcW98XWWZGN1SbJaDL7vev55fW', 'admin', '2026-04-23 07:39:01'),
(4, 'Administrator', 'admin@edu.local', '$2y$12$/vb02R0G2WD7H0z8tiIn6ebWrkiPcW98XWWZGN1SbJaDL7vev55fW', 'admin', '2026-05-07 08:57:38'),
(6, 'firas', 'firas@gmail.com', '$2y$12$VotFx5osTtKi84EYefaFquJ1o44CnemhuTjk8T4nJfE7DpwM9wAoS', 'student', '2026-06-02 08:47:54'),
(7, 'imen', 'imen@gmail.com', '$2y$12$uh/EjahvMIp1guRirYKv9.umwIArwZh3r5XC6XhkDCjvitRj8UCDu', 'teacher', '2026-06-02 08:49:36');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_products_by_price`
-- (See below for the actual view)
--
CREATE TABLE `view_products_by_price` (
`id` int(10) unsigned
,`product_name` varchar(200)
,`price` decimal(10,2)
,`stock_quantity` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_products_mid_stock`
-- (See below for the actual view)
--
CREATE TABLE `view_products_mid_stock` (
`id` int(10) unsigned
,`product_name` varchar(200)
,`price` decimal(10,2)
,`stock_quantity` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_users_alphabetical`
-- (See below for the actual view)
--
CREATE TABLE `view_users_alphabetical` (
`id` int(10) unsigned
,`full_name` varchar(120)
,`email` varchar(180)
,`role` enum('admin','teacher','student')
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Structure for view `view_products_by_price`
--
DROP TABLE IF EXISTS `view_products_by_price`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_products_by_price`  AS SELECT `products`.`id` AS `id`, `products`.`product_name` AS `product_name`, `products`.`price` AS `price`, `products`.`stock_quantity` AS `stock_quantity` FROM `products` ORDER BY `products`.`price` ASC  ;

-- --------------------------------------------------------

--
-- Structure for view `view_products_mid_stock`
--
DROP TABLE IF EXISTS `view_products_mid_stock`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_products_mid_stock`  AS SELECT `products`.`id` AS `id`, `products`.`product_name` AS `product_name`, `products`.`price` AS `price`, `products`.`stock_quantity` AS `stock_quantity` FROM `products` WHERE `products`.`stock_quantity` >= 10 AND `products`.`stock_quantity` <= 3030  ;

-- --------------------------------------------------------

--
-- Structure for view `view_users_alphabetical`
--
DROP TABLE IF EXISTS `view_users_alphabetical`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_users_alphabetical`  AS SELECT `users`.`id` AS `id`, `users`.`full_name` AS `full_name`, `users`.`email` AS `email`, `users`.`role` AS `role`, `users`.`created_at` AS `created_at` FROM `users` ORDER BY `users`.`full_name` ASC  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `teacher_id` (`teacher_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sender_id` (`sender_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
