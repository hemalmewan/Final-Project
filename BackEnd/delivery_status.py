from pydantic import  BaseModel

class DeliveryInput(BaseModel):
    price: float 
    shipping: float
    assembly_cost: float
    delivery_days: int 
    rating: float
    category: str
    subcategory: str 
    brand: str 
    assembly: str 
    payment: str 
    timing: str 