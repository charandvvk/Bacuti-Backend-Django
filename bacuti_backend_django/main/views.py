from django.shortcuts import render

# Create your views here.

from django.http import JsonResponse
from .models import Products, Subassemblies, Components, Emissions

def fetch_products_data():
    products = Products.objects.all()
    products_data = []
    for product in products:
        subassemblies = Subassemblies.objects.filter(product=product)
        components = Components.objects.filter(product=product)
        products_data.append({
            "product_id": product.product_id,
            "name": product.name,
            "subassemblies_data": list(subassemblies.values()),
            "components_data": list(components.values())
        })
    return products_data

def calculate_total_quantity(subassembly_parent_id, quantity, subassemblies_data):
    total_quantity = quantity
    current_subassembly_parent_id = subassembly_parent_id
    while current_subassembly_parent_id:
        subassembly_data = [subassembly for subassembly in subassemblies_data if subassembly["subassembly_id"] == subassembly_parent_id][0]
        total_quantity *= subassembly_data["quantity"]
        current_subassembly_parent_id = subassembly_data["subassembly_parent_id"]
    return total_quantity

def column_model(emission_type):
    result = {}
    products_data = fetch_products_data()
    for product_data in products_data:
        for component_data in product_data["components_data"]:
            total_quantity = calculate_total_quantity(component_data["subassembly_parent_id"], component_data["quantity"], product_data["subassemblies_data"])
            emissions = Emissions.objects.filter(component=component_data["component_id"])
            for emission in emissions:
                month = emission.month
                category = emission.category
                value = getattr(emission, emission_type)
                if not month in result:
                    result[month] = {"Actual": 0, "Plan": 0}
                result[month][category] += value * total_quantity
    return result

def table_model():
    result = {}
    products_data = fetch_products_data()
    for product_data in products_data:
        result[str(product_data["product_id"])] = {
            "name": product_data["name"],
            "type": "product",
            "scope_1": 0,
            "scope_2": 0,
            "scope_3": 0,
            "subassemblies": {},
            "components": {}
        }
        for component_data in product_data["components_data"]:
            total_quantity = calculate_total_quantity(component_data["subassembly_parent_id"], component_data["quantity"], product_data["subassemblies_data"])
            component = {
                "name": component_data["name"],
                "type": "component",
                "parentId": component_data["subassembly_parent_id"] or product_data["product_id"],
                "scope_1": 0,
                "scope_2": 0,
                "scope_3": 0
            }
            emissions = Emissions.objects.filter(component=component_data["component_id"], category="Actual")
            for emission in emissions:
                component["scope_1"] += emission.scope_1 * total_quantity
                component["scope_2"] += emission.scope_2 * total_quantity
                component["scope_3"] += emission.scope_3 * total_quantity
            result[str(product_data["product_id"])]["components"][str(component_data["component_id"])] = component
            subassembly_parent_id = component_data["subassembly_parent_id"]
            while subassembly_parent_id:
                subassembly_parent_data = [subassembly for subassembly in product_data["subassemblies_data"] if subassembly["subassembly_id"] == subassembly_parent_id][0]
                if str(subassembly_parent_id) not in result[str(product_data["product_id"])]["subassemblies"]:
                    result[str(product_data["product_id"])]["subassemblies"][str(subassembly_parent_id)] = {
                        "name": subassembly_parent_data["name"],
                        "type": "subassembly",
                        "parentId": subassembly_parent_data["subassembly_parent_id"] or product_data["product_id"],
                        "scope_1": 0,
                        "scope_2": 0,
                        "scope_3": 0
                    }
                result[str(product_data["product_id"])]["subassemblies"][str(subassembly_parent_id)]["scope_1"] += component["scope_1"]
                result[str(product_data["product_id"])]["subassemblies"][str(subassembly_parent_id)]["scope_2"] += component["scope_2"]
                result[str(product_data["product_id"])]["subassemblies"][str(subassembly_parent_id)]["scope_3"] += component["scope_3"]
                subassembly_parent_id = subassembly_parent_data["subassembly_parent_id"]
            result[str(product_data["product_id"])]["scope_1"] += component["scope_1"];
            result[str(product_data["product_id"])]["scope_2"] += component["scope_2"];
            result[str(product_data["product_id"])]["scope_3"] += component["scope_3"];
    return result

def pie_model():
    result = {
        "scope1": 0,
        "scope2": 0,
        "category1": 0,
        "category5": 0,
        "category12": 0,
    }
    products_data = fetch_products_data()
    for product_data in products_data:
        for component_data in product_data["components_data"]:
            total_quantity = calculate_total_quantity(component_data["subassembly_parent_id"], component_data["quantity"], product_data["subassemblies_data"])
            emissions = Emissions.objects.filter(component=component_data["component_id"], category="Actual")
            for emission in emissions:
                result["scope1"]+=emission.scope_1*total_quantity
                result["scope2"]+=emission.scope_2*total_quantity
                result["category1"]+=emission.category_1*total_quantity
                result["category5"]+=emission.category_5*total_quantity
                result["category12"]+=emission.category_12*total_quantity
    return result

def handle_request(callback):
    try:
        result = callback()
        return JsonResponse(result, safe=False)
    except Exception as error:
        print(error)
        return JsonResponse({"error": "Internal Server Error"}, status=500)

def column_view(_, emission_type):
    return handle_request(lambda: column_model(emission_type))

def table_view(_):
    return handle_request(table_model)

def pie_view(_):
    return handle_request(pie_model)