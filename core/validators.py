"""Validaciones reutilizables. Responsable: B.
Cada función devuelve (valor, error): si error es None, el dato es válido."""
from decimal import Decimal, InvalidOperation


def validar_precio(texto):
    try:
        valor = Decimal(texto.strip())
    except (InvalidOperation, AttributeError):
        return None, "Ingrese un número válido"
    if valor < 0:
        return None, "No puede ser negativo"
    return valor, None


def validar_cantidad(texto):
    texto = texto.strip()
    if not texto.isdigit():
        return None, "Solo números enteros"
    cantidad = int(texto)
    if cantidad <= 0:
        return None, "Debe ser mayor que cero"
    return cantidad, None
