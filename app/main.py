from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import LcdController

app = FastAPI()

app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,   # 追記により追加
        allow_methods=["*"],      # 追記により追加
        allow_headers=["*"]       # 追記により追加
)

class Sip(BaseModel):
    status: str
    phone_number: str

talk_timer = LcdController.TalkTimer()

@app.get("/data/indoor")
async def indoor():
    return {"tempreture": 20.5, "humidity": 50.0}

@app.post("/sip/start")
def sip_start(sip: Sip):
    LcdController.display_infomation("SIP Call from", " " + sip.phone_number)
    return "done"

@app.post("/sip/connected")
def sip_connected(sip: Sip):
    talk_timer.line1 = sip.phone_number
    talk_timer.status = sip.status
    talk_timer.begin()
    return "done"

@app.get("/sip/disconnected")
def sip_disconnected():
    talk_timer.end()
    LcdController.display_backlight_off()
    return "done"

@app.get("/this/destroy")
def this_destroy():
    talk_timer.kill()
    return "done"
