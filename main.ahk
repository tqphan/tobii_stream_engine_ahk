#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Ptr := A_PtrSize ? "Ptr" : "UInt"

if not url_receiver_address
    url_receiver_address := RegisterCallback("url_receiver", "Fast", 2)
if not gaze_point_callback_address
    gaze_point_callback_address := RegisterCallback("gaze_point_callback", "Fast", 2)
global api, device, url

err := DllCall("tobii_stream_engine\tobii_api_create", "IntP", api, "int", 0, "int", 0)
err := DllCall("tobii_stream_engine\tobii_enumerate_local_device_urls", "Int", api, "Ptr", url_receiver_address, "AStrP", 0)
err := DllCall("tobii_stream_engine\tobii_device_create", "Int", api, "AStr", url, "IntP", device)
err := DllCall("tobii_stream_engine\tobii_gaze_point_subscribe", "Int", device, "Ptr", gaze_point_callback_address, "Int", 0)

Loop, 50
{
    err := DllCall("tobii_stream_engine\tobii_wait_for_callbacks", "Int", 1, "IntP", device)
    err := DllCall("tobii_stream_engine\tobii_device_process_callbacks", "Int", device)
}

err := DllCall("tobii_stream_engine\tobii_gaze_point_unsubscribe", "Int", device)
err := DllCall("tobii_stream_engine\tobii_device_destroy", "Int", device)
err := DllCall("tobii_stream_engine\tobii_api_destroy", "Int", api)

url_receiver(a, user_data)
{
    se := StrGet(a,"cp0")
    url := se
    OutputDebug, %url%
}

gaze_point_callback(gaze_point, user_data)
{
    time_stamp := NumGet(gaze_point + 0, "Int64")
    validity := NumGet(gaze_point + 8, "Int")
    x := NumGet(gaze_point + 12, "Float")
    y := NumGet(gaze_point + 16, "Float")
    OutputDebug, t - %time_stamp% x: %x% y: %y%
}

assert(lhs, rhs)
{
    if lhs != rhs
        OutputDebug, %lhs% . " " . %rhs%
}