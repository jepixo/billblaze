import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

final kernel32 = DynamicLibrary.open('kernel32.dll');

final CreateMutex = kernel32.lookupFunction<
    Pointer<COMObject> Function(
        Pointer<SECURITY_ATTRIBUTES> lpMutexAttributes,
        Int32 bInitialOwner,
        Pointer<Utf16> lpName),
    Pointer<COMObject> Function(
        Pointer<SECURITY_ATTRIBUTES> lpMutexAttributes,
        int bInitialOwner,
        Pointer<Utf16> lpName)>('CreateMutexW');

Pointer<COMObject>? createMutex(String name) {
  final kernel32 = DynamicLibrary.open('kernel32.dll');
  
  final CreateMutexW = kernel32.lookupFunction<
      Pointer<COMObject> Function(
          Pointer<SECURITY_ATTRIBUTES> lpMutexAttributes,
          Int32 bInitialOwner,
          Pointer<Utf16> lpName),
      Pointer<COMObject> Function(
          Pointer<SECURITY_ATTRIBUTES> lpMutexAttributes,
          int bInitialOwner,
          Pointer<Utf16> lpName)>('CreateMutexW');

  final namePtr = name.toNativeUtf16();
  final mutexHandle = CreateMutexW(nullptr, FALSE, namePtr);
  calloc.free(namePtr);
  return mutexHandle;
}

const int WM_COPYDATA = 0x004A;

final class COPYDATASTRUCT extends ffi.Struct {
  @ffi.IntPtr()
  external int dwData;
  @ffi.Int32()
  external int cbData;
  external ffi.Pointer<ffi.Void> lpData;
}

// typedef WNDPROC = ffi.Int32 Function(
//   ffi.IntPtr hwnd,
//   ffi.Uint32 msg,
//   ffi.IntPtr wParam,
//   ffi.IntPtr lParam,
// );

int myWndProc(int hwnd, int msg, int wParam, int lParam) {
  return DefWindowProc(hwnd, msg, wParam, lParam);
}