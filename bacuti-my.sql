SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `bacuti`
--

DROP DATABASE IF EXISTS `bacuti`;

CREATE DATABASE `bacuti`;

USE `bacuti`;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` CHAR(36),
  `name` TINYTEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`) VALUES
(UUID(), 'Car');

-- --------------------------------------------------------

--
-- Table structure for table `subassemblies`
--

CREATE TABLE `subassemblies` (
  `subassembly_id` CHAR(36),
  `product_id` CHAR(36) NOT NULL,
  `subassembly_parent_id` CHAR(36),
  `name` TINYTEXT NOT NULL,
  `quantity` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subassemblies`
--

SET @product_id = (SELECT `product_id` FROM `products` WHERE `name` = 'Car');

INSERT INTO `subassemblies` (`subassembly_id`, `product_id`, `subassembly_parent_id`, `name`, `quantity`) VALUES
(UUID(), @product_id, NULL, 'Wheel Assembly', 4),
(UUID(), @product_id, NULL, 'Brake Assembly', 4),
(UUID(), @product_id, NULL, 'Light System', 1);

-- --------------------------------------------------------

--
-- Table structure for table `components`
--

CREATE TABLE `components` (
  `component_id` CHAR(36),
  `product_id` CHAR(36) NOT NULL,
  `subassembly_parent_id` CHAR(36),
  `name` TINYTEXT NOT NULL,
  `quantity` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `components`
--

SET @wheelAssembly_id = (SELECT `subassembly_id` FROM `subassemblies` WHERE `name` = 'Wheel Assembly');
SET @brakeAssembly_id = (SELECT `subassembly_id` FROM `subassemblies` WHERE `name` = 'Brake Assembly');
SET @lightSystem_id = (SELECT `subassembly_id` FROM `subassemblies` WHERE `name` = 'Light System');

INSERT INTO `components` (`component_id`, `product_id`, `subassembly_parent_id`, `name`, `quantity`) VALUES
(UUID(), @product_id, NULL, 'Transmission', 1),
(UUID(), @product_id, NULL, 'Bucket Seats', 2),
(UUID(), @product_id, NULL, 'Back Seat', 1),
(UUID(), @product_id, @wheelAssembly_id, 'Nuts', 8),
(UUID(), @product_id, @wheelAssembly_id, 'Tire', 1),
(UUID(), @product_id, @wheelAssembly_id, 'Faceplate', 1),
(UUID(), @product_id, @brakeAssembly_id, 'Brake Pads', 2),
(UUID(), @product_id, @brakeAssembly_id, 'Disks', 1),
(UUID(), @product_id, @brakeAssembly_id, 'Nuts', 4),
(UUID(), @product_id, @lightSystem_id, 'Front Lights', 2),
(UUID(), @product_id, @lightSystem_id, 'Rear Lights', 2),
(UUID(), @product_id, @lightSystem_id, 'Turning Lights', 4),
(UUID(), @product_id, @lightSystem_id, 'Interior', 1),
(UUID(), @product_id, @lightSystem_id, 'Turning Switch', 1),
(UUID(), @product_id, @lightSystem_id, 'Door Switch', 4),
(UUID(), @product_id, @lightSystem_id, 'Overhead Switch', 1);

-- --------------------------------------------------------

--
-- Table structure for table `emissions`
--

CREATE TABLE `emissions` (
  `emission_id` INT,
  `component_id` CHAR(36) NOT NULL,
  `month` ENUM('Jan', 'Feb', 'Mar',
           'Apr', 'May', 'Jun',
           'Jul', 'Aug') NOT NULL,
  `category` ENUM('Plan', 'Actual') NOT NULL,
  `pef_total` INT NOT NULL,
  `scope_1` INT NOT NULL,
  `scope_2` INT NOT NULL,
  `scope_3` INT NOT NULL,
  `category_1` INT NOT NULL,
  `category_5` INT NOT NULL,
  `category_12` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `subassemblies`
--
ALTER TABLE `subassemblies`
  ADD PRIMARY KEY (`subassembly_id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Indexes for table `components`
--
ALTER TABLE `components`
  ADD PRIMARY KEY (`component_id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Indexes for table `emissions`
--
ALTER TABLE `emissions`
  ADD PRIMARY KEY (`emission_id`),
  ADD KEY `idx_component_id` (`component_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `product_secondary_functions`
--
ALTER TABLE `emissions`
  MODIFY `emission_id` INT AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `subassemblies`
--
ALTER TABLE `subassemblies`
  ADD CONSTRAINT `subassemblies_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`),
  ADD CONSTRAINT `subassemblies_ibfk_2` FOREIGN KEY (`subassembly_parent_id`) REFERENCES `subassemblies`(`subassembly_id`);

--
-- Constraints for table `components`
--
ALTER TABLE `components`
  ADD CONSTRAINT `components_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`),
  ADD CONSTRAINT `components_ibfk_2` FOREIGN KEY (`subassembly_parent_id`) REFERENCES `subassemblies`(`subassembly_id`);

--
-- Constraints for table `emissions`
--
ALTER TABLE `emissions`
  ADD CONSTRAINT `emissions_ibfk_1` FOREIGN KEY (`component_id`) REFERENCES `components`(`component_id`);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

