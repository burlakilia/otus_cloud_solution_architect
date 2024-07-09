import {useState, useCallback} from 'react';
import * as ReactDOM from "react-dom";
import { FormField, Button, Form } from 'semantic-ui-react'
import './index.css';
import 'semantic-ui-css/semantic.css'

import {
    Route,
    Routes,
    HashRouter as Router,
    useNavigate,
} from 'react-router-dom';

// @ts-ignore
const REST_APP_ID = window.REST_APP_ID;

function App() {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<Login/>}/>
                <Route path="/create" element={<Create/>}/>
            </Routes>
        </Router>
    )
}

function Create() {
    const navigate = useNavigate();
    const [appName, setAppName] = useState('');
    const [appDesc, setAppDesc] = useState('');
    const [loading, setLoading] = useState(false);

    const token = sessionStorage.getItem('token');

    if (!token) {
        navigate('/');
    }

    const handleSubmit = useCallback(async (e: any) => {
        e.preventDefault();
        setLoading(true)

        const data = await fetch(`https://${REST_APP_ID}.apigw.yandexcloud.net/create`, {
            method: 'POST',
            body: JSON.stringify({appName, appDesc, token})
        }).then(res => res.json()).finally(() => setLoading(false));

        console.log(data);
    }, [appName, appDesc, setLoading])

    return (
        <Form>
            <FormField>
                <label>AppName</label>
                <input placeholder='AppName' onChange={(e) => setAppName(e.target.value)}/>
            </FormField>
            <FormField>
                <label>Desc</label>
                <input placeholder='Desc' onChange={(e) => setAppDesc(e.target.value)}/>
            </FormField>
            <Button disabled={loading} type='submit' onClick={handleSubmit}>Create App</Button>
        </Form>
    )
}

function Login() {
    const [login, setLogin] = useState('');
    const [pwd, setPwd] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleSubmit = useCallback(async (e: any) => {
        e.preventDefault();
        setLoading(true)

        const data = await fetch(`https://${REST_APP_ID}.apigw.yandexcloud.net/auth`, {
            method: 'POST',
            body: JSON.stringify({login,pwd})
        }).then(res => res.json()).finally(() => setLoading(false));

        sessionStorage.setItem('token', data.token);
        navigate('/create')
    }, [login, pwd, setLoading])

    return (
        <Form>
            <FormField>
                <label>Login</label>
                <input placeholder='Login' onChange={(e) => setLogin(e.target.value)}/>
            </FormField>
            <FormField>
                <label>Password</label>
                <input placeholder='Password' onChange={(e) => setPwd(e.target.value)}/>
            </FormField>
            <Button disabled={loading} type='submit' onClick={handleSubmit}>Sign in</Button>
        </Form>
    )
}

ReactDOM.render(
    // @ts-ignore
    <App/>,
    document.body
);
