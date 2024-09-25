# Inventory Optimization using MySQL

## Business Overview

TechElectro Inc. is facing several inventory management challenges affecting operational efficiency and customer satisfaction:

- **Overstocking**: Excess inventory leads to tied-up capital and limited storage capacity.
- **Understocking**: Stockouts for high-demand products result in missed sales opportunities.
- **Customer Satisfaction**: Delays and frequent stockouts negatively impact customer satisfaction and loyalty.

## Project Objective

The project aims to implement a MySQL-powered inventory optimization system to address the following:

- **Optimal Inventory Levels**: Balance stock levels to reduce both overstock and understock situations.
- **Data-Driven Decisions**: Use MySQL analytics to optimize inventory, lowering costs and improving customer satisfaction.

## Data Description

The project includes three datasets:

- **Sales Data**:
  - `Product ID`: Unique identifier for products.
  - `Sales Date`: Date of sale.
  - `Sales Quantity (Units)`: Number of units sold.
  - `Product Cost (USD per Unit)`: Cost per unit in USD.

- **Product Information Data**:
  - `Product ID`: Unique product identifier.
  - `Product Category`: Category of the product.
  - `Promotions`: Indicator of ongoing promotions.

- **External Information Data**:
  - `Sales Date`: Date of product sale.
  - `GDP (USD)`: Economic data in USD.
  - `Inflation Rate (%)`: Percentage price change.
  - `Seasonal Factor`: Index for seasonality effects.

## Tech Stack

- **MySQL**: Used for data analysis, mathematical operations, and optimization techniques.

## Project Scope

- **Exploratory Data Analysis (EDA)**: Use MySQL to uncover patterns and correlations.
- **Inventory Optimization**: Apply SQL techniques to determine optimal stock levels for each product.
- **Documentation**: Provide MySQL scripts and a user guide for easy implementation.
- **Deployment**: Integrate the MySQL solution with existing systems for real-time inventory management.

## General Insights

1. **Inventory Discrepancies**: Both overstocking and understocking contribute to inefficiencies.
2. **Sales Trends & External Factors**: Sales are influenced by external factors such as GDP, inflation, and seasonality.
3. **Suboptimal Inventory Levels**: The current inventory is not aligned with actual sales patterns.

## Recommendations

- **Dynamic Inventory Management**: Transition to a real-time inventory system to balance stock levels.
- **Optimize Reorder Points**: Regularly review and adjust reorder points and safety stocks.
- **Refine Pricing Strategies**: Reevaluate pricing for underperforming products based on market conditions.
- **Reduce Overstock**: Address overstocking through promotions, discounts, or discontinuation of low-selling products.
- **Feedback Loop**: Implement a feedback system for continuous improvement in inventory strategies.
- **Regular Monitoring**: Continuously track inventory levels and adjust based on demand fluctuations.

