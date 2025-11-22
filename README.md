# Inteligent-Vaacum-Cleaner-IIA---NetLogo

**Course:** Artificial Intelligence (IIA)  
**Academic Year:** 2024/2025  
**Project:** TP1 — Autonomous Vacuum Cleaner Simulation

## Authors
- **Duarte Santos** — 2022149622  
- **Gustavo Costa** — 2023145800  

---

## 📘 Description
This project implements a simulation of autonomous vacuum cleaners using **NetLogo**.  
Each vacuum cleaner behaves as an intelligent agent capable of:

- Navigating through the environment  
- Collecting dirt (red patches)  
- Recharging energy at charging stations (blue patches)  
- Emptying collected dirt in deposit areas (green patches)  
- Avoiding obstacles (white patches)  
- Handling carpets that reduce speed (grey patches)  
- Reproducing (optional)  
- Dealing with defects or failures (optional)  

---

## 📁 Project Structure
```text
Trabalho_pratico/
├── tp1.nlogo                          # NetLogo Source Code
├── IIA_2425_TP1.pdf                   # Project Assignment Brief
├── Relatorio.pdf                      # Final Report
└── README.md                          # Project Documentation
```

---

## 🧩 Requirements
- **NetLogo 6.4.0** or higher

---

## ▶️ How to Run
1. Open **NetLogo**
2. Load the file **`tp1.nlogo`**
3. Configure the parameters in the interface:

   | Parameter | Description |
   |----------|-------------|
   | `nCarregadores` | Number of charging stations |
   | `pLixo` | Percentage of dirt in the environment |
   | `nAspiradores` | Initial number of vacuum agents |
   | `nEnergia` | Initial energy of each agent |
   | `nCapacidade` | Maximum dirt capacity |
   | `nIrCarregar` | Energy threshold to start recharging |
   | `tDespejar` | Time required to empty collected dirt |
   | `tCarga` | Time required to recharge |
   | `reproducao?` | Enable/disable reproduction |
   | `tapete?` | Enable/disable carpets |
   | `defeitos-aspirador?` | Enable/disable agent defects |

4. Press **SETUP** to initialize the simulation  
5. Press **GO** to start the simulation  

---

## 🤖 Implemented Features

### Vacuum Cleaner Behavior
- **Navigation:** Intelligent movement and environment exploration  
- **Dirt Collection:** Detects and collects dirt patches  
- **Energy Management:** Automatically seeks charging stations  
- **Capacity Management:** Empties dirt when full  
- **Obstacle Avoidance:** Detects and avoids walls and obstacles  
- **Location Memory:** Stores known charging stations and deposit zones  
- **Communication:** Shares knowledge with nearby agents  
- **Reproduction:** Can generate new vacuum agents (optional)  
- **Defects:** Agents may fail or break down over time (optional)  

### Environment Elements
- **Red:** Dirt to be collected  
- **Blue:** Charging stations  
- **Green:** Dirt deposit areas  
- **White:** Obstacles  
- **Grey:** Carpets that reduce movement speed  
- **Black:** Free navigable space  

---

## ⚙️ Simulation Parameters

| Parameter | Description | Default |
|----------|-------------|---------|
| **nCarregadores** | Charging stations count | 5 |
| **pLixo** | Dirt percentage | 40 |
| **nAspiradores** | Initial number of agents | 10 |
| **nEnergia** | Initial energy | 100 |
| **nCapacidade** | Max dirt capacity | 15 |
| **nIrCarregar** | Energy threshold to recharge | 65 |
| **tDespejar** | Time to empty dirt | 20 |
| **tCarga** | Time to charge | 20 |

---

## 🧪 Experiments
The model includes two predefined experiments:

- **experiment:** Base experiment using default settings  
- **experimento_vAgentes:** Experiment with multiple agents and carpets enabled  

---

## 📝 Notes
- Agents die when their energy reaches zero  
- Defective agents have a limited number of movements before failing  
- Reproduction only occurs when energy is full  
- Carpets reduce movement speed to **0.25 units per tick**  

---

## 📄 License
This project was developed for academic purposes as part of the **Artificial Intelligence** course.
