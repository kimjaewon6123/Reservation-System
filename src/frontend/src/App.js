import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material';
import CssBaseline from '@mui/material/CssBaseline';
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Button from '@mui/material/Button';

// 테마 설정
const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
  typography: {
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif',
    ].join(','),
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Box sx={{ flexGrow: 1 }}>
          <AppBar position="static">
            <Toolbar>
              <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                SCRS - 스마트 카페 예약 시스템
              </Typography>
              <Button color="inherit">로그인</Button>
              <Button color="inherit">회원가입</Button>
            </Toolbar>
          </AppBar>
          
          <Container maxWidth="lg" sx={{ mt: 4 }}>
            <Box sx={{ 
              bgcolor: 'background.paper',
              pt: 8,
              pb: 6,
              textAlign: 'center'
            }}>
              <Typography
                component="h1"
                variant="h2"
                color="text.primary"
                gutterBottom
              >
                환영합니다!
              </Typography>
              <Typography variant="h5" color="text.secondary" paragraph>
                SCRS에서 편리하게 카페를 예약하세요.
                실시간으로 좌석 현황을 확인하고, 
                원하는 시간에 미리 예약할 수 있습니다.
              </Typography>
              <Box sx={{ mt: 4 }}>
                <Button variant="contained" size="large" sx={{ mr: 2 }}>
                  매장 둘러보기
                </Button>
                <Button variant="outlined" size="large">
                  예약하기
                </Button>
              </Box>
            </Box>
          </Container>
        </Box>
      </Router>
    </ThemeProvider>
  );
}

export default App;
