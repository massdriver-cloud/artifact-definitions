# Creating a Snowflake user with private key for Massdriver

## How Massdriver uses your Snowflake credentials

To keep your environment secure, Massdriver uses a dedicated user account with private key authentication to access your Snowflake instance for provisioning and monitoring of your infrastructure. This user should have administrative privileges to manage databases, warehouses, and other resources.

## Step 1

### Generate a Secure Shell (SSH) key pair

Open your terminal and generate an SSH key pair:

```bash
# Generate a private key
ssh-keygen -t rsa -b 2048 -f snowflake_massdriver_key

# Generate the public key
ssh-keygen -y -f snowflake_massdriver_key > snowflake_massdriver_key.pub
```

&nbsp;

## Step 2

### Log in to Snowflake Web Interface

Open your browser and navigate to your Snowflake account at https://ACCOUNT_NAME.snowflake.com.

&nbsp;

## Step 3

### Navigate to Users & Roles menu

From the left navigation menu, click on **Users & Roles** to expand the section, then click on **Users**.

&nbsp;

## Step 4

### Create a new user

Click the **Create User** button in the top right corner of the Users page.

&nbsp;

## Step 5

### Fill in the user details

In the **Create User** dialog, fill in the following details:

- **User Name**: `snowflake_massdriver_user`
- **Authentication Method**: Select **SSH Public Key**
- **Public Key**: Copy the contents of the `snowflake_massdriver_key.pub` file
- [ ] [ ] **Must Change Password on Next Login**

&nbsp;

## Step 6

### Assign roles to the user

In the **Roles** section of the dialog:

- Click the **Add Roles** button
- Select **ACCOUNTADMIN** from the role list
- Click **OK**

&nbsp;

## Step 7

### Configure warehouse access

In the **Warehouses** section:

- Click the **Add Warehouses** button
- Select **CURRENT** from the warehouse list
- Click **OK**

&nbsp;

## Step 8

### Configure database access

In the **Databases** section:

- Click the **Add Databases** button
- Select **CURRENT** from the database list
- Click **OK**

&nbsp;

## Step 9

### Create the user

Click the **Create User** button to complete the user creation.

&nbsp;

## Step 10

### Get the account information

To get the account information needed for Massdriver:

1. Go to the **Administration** page from the left navigation
2. Click on **Accounts**
3. Copy the **Account Locator** value (this is your account name)
4. Copy the **Region** value (this is your region)

&nbsp;

## Step 11

### Import credentials to Massdriver

In Massdriver, fill in the following fields:

- **Account** (Account Locator from Step 10)
- **Username** (snowflake_massdriver_user)
- **Private Key** (the contents of the `snowflake_massdriver_key` file)
- **Region** (Region from Step 10)

Click **Create** and head to the [projects page](/projects) to start building your infrastructure.
