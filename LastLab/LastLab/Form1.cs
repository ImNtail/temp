using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LastLab
{
    public partial class Form1 : Form
    {
        Graphics dc; Pen p;
        /* Коэффициенты матрицы видового преобразования */
        double v11, v12, v13, v21, v22, v23, v32, v33, v43;
        /* Сферические координаты точки наблюдения */
        double rho = 150.0, theta = 320.0, phi = 45.0;
        /* Расстояние от точки наблюдения до экрана */
        double screen_dist = 100.0;
        /* Cмещение относительно левого нижнего угла экрана */
        double c1 = 5.0, c2 = 3.5;
        /* Половина длины ребра куба */
        double h = 1;
        //кол-во кубов
        double figuresNumber;
        bool down;

        private void pictureBox2_MouseDown(object sender, MouseEventArgs e)
        {
            down = true;
        }

        private void pictureBox2_MouseMove(object sender, MouseEventArgs e)
        {
            Control c = sender as Control;
            if (down)
            {
                if (c.Location.Y + c.Height < pictureBox1.Height)
                    c.Location = this.PointToClient(new Point(Control.MousePosition.X - c.Width / 2, Control.MousePosition.Y - c.Height / 2));
                else if (c.Location.Y + c.Height >= pictureBox1.Height)
                {
                    c.Location = this.PointToClient(new Point(Control.MousePosition.X - c.Width / 2, Control.MousePosition.Y - c.Height));
                    down = false;
                }
            }
        }

        private void pictureBox2_MouseUp(object sender, MouseEventArgs e)
        {
            down = false;
        }
        private void timer1_Tick(object sender, EventArgs e)
        {
            /*if (textBox1.Text == "")
                figuresNumber = 1;
            else
                figuresNumber = Convert.ToDouble(textBox1.Text);*/
            coeff(rho, theta, phi);
            drawCube(h, 1);
            if (theta > 359)
                theta = 0;
            if (phi > 359)
                phi = 0;
            theta += 7;
            phi += 7;
        }

        public Form1()
        {
            InitializeComponent();
            pictureBox1.BackColor = Color.White;
            pictureBox2.BackColor = Color.White;
            dc = pictureBox2.CreateGraphics();
            p = new Pen(Brushes.Black, 1);
        }
        private void button1_Click(object sender, EventArgs e)
        {
            if (timer1.Enabled)
                timer1.Stop();
            else
                timer1.Start();
        }
        /* Функция преобразования вещественной координаты X в целую */
        private int IX(double x)
        {
            double xx = x * (pictureBox1.Size.Width / 10.0) + 0.5;        
            return (int)xx;
        }
        /* Функция преобразования вещественной координаты Y в целую */
        private int IY(double y)
        {
            double yy = pictureBox1.Size.Height - y *

            (pictureBox1.Size.Height / 7.0) + 0.5;

            return (int)yy;
        }
        /* Вычисление коэффициентов, не зависящих от вершин куба */
        private void coeff(double rho, double theta, double phi)
        {
            double th, ph, costh, sinth, cosph, sinph, factor;
            factor = Math.PI / 180.0; // из градусов в радианы
            th = theta * factor;
            ph = phi * factor;
            costh = Math.Cos(th);
            sinth = Math.Sin(th);
            cosph = Math.Cos(ph);
            sinph = Math.Sin(ph);
            /* Элементы матрицы V видового преобразования
            | -sin(th) -cos(phi) * cos(th) -sin(phi) * cos(th) 0 |
            V= | cos(th) -cos(phi) * sin(th) -sin(phi) * sin(th) 0 |
            | 0 sin(phi) -cos(phi) 0 |
            | 0 0 rho 1 |
            */
            v11 = -sinth; v12 = -cosph * costh; v13 = -sinph * costh;
            v21 = costh; v22 = -cosph * sinth; v23 = -sinph * sinth;
            v32 = sinph; v33 = -cosph; v43 = rho;
        }
        /* Функция видового и перспективного преобразования координат */
        private void perspective(double x, double y, double z, ref double pX, ref double pY, double num)
        {
            double xe, ye, ze;
            /*координаты точки наблюдения, вычисляемые по уравнению
            [Xe Ye Ze 1]= [Xw Yw Zw 1]*V
            */
            xe = v11 * x + v21 * y;
            ye = v12 * x + v22 * y + v32 * z;
            ze = v13 * x + v23 * y + v33 * z + v43;
            /* Экранные координаты,вычисляемые по формулам
            X= d* (x/z)+c1, Y= d*(y/z)+c2,
            где - расстояние от точки наблюдения до экрана
            */
            /*pX = screen_dist * xe / ze + c1 + num - 3;
            pY = screen_dist * ye / ze + c2 + num * 1.55 - 2;*/
            pX = screen_dist * xe / ze + c1 - 3.8;
            pY = screen_dist * ye / ze + c2 + 2.3;
        }
        /* Функция вычерчивания линии (экран 10х7 условн. единиц) */
        private void dw(double x1, double y1, double z1, double x2, double y2, double z2, double num)
        {
            for (double i = 0; i < num; i++)
            {
                double X1 = 0, Y1 = 0, X2 = 0, Y2 = 0;
                /* Преобразование мировых координат в экранные */
                perspective(x1, y1, z1, ref X1, ref Y1, i);
                perspective(x2, y2, z2, ref X2, ref Y2, i);
                /* Вычерчивание линии */
                Point point1 = new Point(IX(X1), IY(Y1));
                Point point2 = new Point(IX(X2), IY(Y2));
                dc.DrawLine(p, point1, point2);
            }
        }
        /* Функция рисования проволочной модели куба */
        private void drawCube(double h, double num)
        {
            dc.Clear(Color.White);
            dw(h, -h, -h, h, h, -h, num); // Отрезок AB
            dw(h, h, -h, -h, h, -h, num); // Отрезок BC
            dw(-h, h, -h, -h, h, h, num); // Отрезок CG
            dw(-h, h, h, -h, -h, h, num); // Отрезок GH
            dw(-h, -h, h, h, -h, h, num); // Отрезок HE
            dw(h, -h, h, h, -h, -h, num); // Отрезок EA
            dw(h, h, -h, h, h, h, num); // Отрезок BF
            dw(h, h, h, -h, h, h, num); // Отрезок FG
            dw(h, h, h, h, -h, h, num); // Отрезок FE
            dw(h, -h, -h, -h, -h, -h, num); // Отрезок AD
            dw(-h, -h, -h, -h, h, -h, num); // Отрезок DC
            dw(-h, -h, -h, -h, -h, h, num); // Отрезок DH
        }
    }
}
