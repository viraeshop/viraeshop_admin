# Customer Message Box Based Product Price Negotiation System
## (Chat-Driven, Super Admin Approved, Future-Ready)

---

## Core Concept of the System

This module is fully centered around the **Customer Message Box**.

Everything happens inside the chat:
- Product discussion
- Price negotiation
- Final decision

### ⚠️ Very Important Rule

- The **original product price** stored in the main product database must **never change**
- Any negotiated price is **temporary, customer-specific, and approval-based**
- **Only** the product discussed in the chat is affected

---

## How the Message Box Starts

### Step 1: Product View

- Customer views a product on product list or product details page
- There is a button: **"Chat for Price / Message Seller"**

### Step 2: Message Box Opens

When the customer clicks the button:
- A dedicated message box opens
- The message box is attached to that specific product

At the top of the chat, the system automatically shows:
- Product image
- Product name
- Original (base) price
- A clear label: **"You are chatting about this product"**

This avoids confusion for both customer and employee.

---

## What Happens Inside the Message Box

### Normal Conversation

- Customer asks questions (quality, delivery, stock, etc.)
- Employee replies normally

### Price Negotiation

- Customer sends an offer inside the chat (example: quantity + offered price)
- Employee replies with counter offers
- Negotiation continues naturally

### ⚠️ At this stage:
- No product price is changed
- No cart option is enabled
- This is **discussion only**

---

## Final Negotiation Completion (Critical Step)

When both customer and employee agree on a final price:

### Action by Employee

Inside the message box, employee clicks:
**"Finalize Negotiation & Send for Approval"**

This creates a **Final Negotiated Price Request**

Status becomes: **Pending Super Admin Approval**

### ⚠️ Important:
- Customer **cannot** add product to cart
- No special product card is visible yet
- Customer sees a message: _"Negotiation completed. Waiting for approval."_

---

## Super Admin Approval Process

### Super Admin Receives Request

Super Admin can see:
- Customer information
- Product information
- Original product price
- Negotiated price
- Quantity
- Full chat history (read-only)

### Super Admin actions:
- ✅ Approve
- ❌ Reject
- 🔄 Modify & Approve

**This step is the control gate of the system.**

---

## After Super Admin Approval

### If Approved

Customer receives notification:
_"Your negotiated price has been approved"_

Then and only then:
- A **Special Product Card** becomes active for that customer

The card shows:
- Negotiated price
- Quantity
- Validity (7 days)
- ✅ **Add to Cart** button becomes active now

### ⚠️ Notes:
- This card is visible **only** to this customer
- Other customers see the normal price
- Main product database is **untouched**

### If Rejected

- Customer and employee are notified
- Add to Cart remains disabled
- Chat stays open
- A new negotiation can start

---

## Time Limitation (Auto Expiry)

The approved negotiated price is valid for **7 days**

After 7 days:
- Special product card is hidden automatically
- Add to Cart is disabled

If the customer still wants the product:
- They must start a new chat and new negotiation
- Old prices **cannot be reused**

---

## Mandatory Business Rules (For Developer)

- **One customer + one product = one active negotiation**
- Negotiated price is:
  - Customer-specific
  - Product-specific
  - Time-limited
- **Original product price is immutable**
- All actions are linked to chat history (audit-friendly)

---

## Why This System Is Strong for the Future

- Full price control (no random discounts)
- Super Admin approval prevents losses
- High-value product conversion increases
- Easy to extend later with:
  - AI price suggestion
  - CRM integration
  - Voice or call support
  - Sales analytics

**Everything is built on the Message Box architecture.**

---

## One-Line Summary (Very Important)

> **"Price discussion happens in chat, price approval happens with Super Admin, and purchase is allowed only after approval."**