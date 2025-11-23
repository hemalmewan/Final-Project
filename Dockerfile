# Use official lightweight Python image
FROM python:3.10-slim

# Set working directory
WORKDIR  /ml-app

##copy the requirement file 
COPY BackEnd/requirements.txt ./BackEnd/

# Install dependencies
RUN pip install --no-cache-dir -r BackEnd/requirements.txt

##Copy frontend best mode and backend to the conteiner
COPY BackEnd ./BackEnd/
COPY best_model ./best_model/


##Change the working directory
WORKDIR /ml-app/BackEnd


# Expose FastAPI port
EXPOSE 8000

# Start FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
