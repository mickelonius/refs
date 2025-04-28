# Learning Path: React + WebGL + WebAssembly (C++) Web Apps

This curriculum breaks down the essential technologies needed to build full-featured, graphically intense web applications using **React** for UI, **WebGL** for graphics (via Three.js), and **WebAssembly (C++)** for performance-critical modules.

---

## 1. React (Frontend Foundations)

**Goal:** Structure and manage UI in a modern SPA.

### Beginner
- [React Official Tutorial](https://react.dev/learn/tutorial-tic-tac-toe)
- [Codecademy React Track](https://www.codecademy.com/learn/react-101)

### Intermediate
- [Fullstackopen React Chapters](https://fullstackopen.com/en/part1)
- Topics: Routing, API requests, global state

### Advanced
- [EpicReact.dev](https://epicreact.dev/)
- State managers: [Zustand](https://github.com/pmndrs/zustand), [Recoil](https://recoiljs.org/)

---

## 2. WebGL with Three.js (3D Graphics)

**Goal:** Learn 3D graphics in the browser.

### Beginner
- [Three.js Journey](https://threejs-journey.com/)
- [Three.js Fundamentals](https://threejs.org/manual/)

### Intermediate
- [Discover Three.js Book](https://discoverthreejs.com/book/)
- Topics: Cameras, materials, animation, shadows, asset loading

### Advanced
- [The Book of Shaders](https://thebookofshaders.com/)
- Integrate with physics: `cannon-es`, or build your own via WASM

---

## 3. react-three-fiber (React + Three.js)

**Goal:** Use declarative React to build 3D scenes.

### Tutorials
- [Official R3F Docs](https://docs.pmnd.rs/react-three-fiber/getting-started/introduction)
- [R3F Basics on YouTube](https://www.youtube.com/watch?v=1rP3nNY2hTo)
- [Fireship React-Three](https://www.youtube.com/watch?v=MiQ2b6T3O4g)

### Libraries
- [@react-three/drei](https://github.com/pmndrs/drei)
- [@react-three/cannon](https://github.com/pmndrs/use-cannon)

---

## 4. WebAssembly with C++

**Goal:** Build high-performance modules in C++ and run them in the browser.

### Install Emscripten
- [Emscripten SDK Guide](https://emscripten.org/docs/getting_started/downloads.html)

### Beginner
- [Wasm C++ Hello World](https://dev.to/iprosk/cc-code-in-react-using-webassembly-7ka)
- [MDN WebAssembly Guide](https://developer.mozilla.org/en-US/docs/WebAssembly/C_to_wasm)

### Intermediate
- [Google C++ to Wasm Guide](https://developers.google.com/web/updates/2019/02/getting-started-with-webassembly)
- Understand: `emcc`, `cwrap`, `MODULARIZE`, `EXPORTED_FUNCTIONS`

### Advanced
- Advanced memory layout
- C++17/20 WebAssembly compatibility
- Threading, SharedArrayBuffer, SIMD (in supported environments)

---

## 5. Integration Projects (All Together)

### Game-Style Starter
- [react-three-next](https://github.com/pmndrs/react-three-next)
- [three-react-cannon-examples](https://github.com/LiamOsler/three-react-cannon-examples)

### Simulation-Style Starter
- [react-wasm-demo](https://github.com/bobbiec/react-wasm-demo)
- [Create WASM + React App](https://dev.to/rajatjindal/webassembly-from-c-to-react-app-using-emscripten-4n4c)

---

## Want More?

Ask ChatGPT for example repos, custom starter templates, performance tuning advice, or help writing your first C++ → WASM module!

